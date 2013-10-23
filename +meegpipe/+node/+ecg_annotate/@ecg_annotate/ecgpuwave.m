function [info, hrvInfo] = ecgpuwave(obj, data)
% ecgpuwave - QRS detection and ECG delineation as in [1]
%
% ````matlab
% info = ecgpuwave(obj, data)
% ````
%
% Where
%
%
%   `info` is a struct with the following fields:
%
%   time    : (cell) An Mx1 cell array of strings with the sampling times
%             of M annotations
%
%   sample  : (int32) An Mx1 cell array with the sample position of each
%             annotation
%
%   ann     : (cell) An Mx1 cell array of strings with annotation codes.
%             See [2] for information regarding these codes.
%
%   subtyp  : (int32) An Mx1 numeric array with sub-type information.
%
%   num     : (int32) An Mx1 numeric array with the num property associated
%              to each annotation
%
%
% References:
%
% [1] Laguna P, Jané R, Caminal P. Automatic Detection of Wave Boundaries
%     in Multilead ECG Signals: Validation with the CSE Database. Computers
%     and Biomedical Research 27(1):45-60, 1994.
%
% [2] http://www.physionet.org/physiobank/annotations.shtml
%
% [3] http://www.physionet.org/physiotools/
%
% [4] http://www.physionet.org/physiotools/wfdb-windows-quick-start.shtml
%
%
% See also: ecg_annotate


import mperl.file.spec.*;
import io.conversion.edf2mit;
import io.edf.write;
import goo.globals;
import datahash.DataHash;
import misc.system;
import pset.session;
import fmrib.my_fmrib_qrsdetect;
import meegpipe.node.ecg_annotate.ecg_annotate;

if isunix,
    CMD_SEP = ' ; ';
else
    CMD_SEP = ' & ';
end

verbose = is_verbose(obj);

sr = data.SamplingRate;

% Guess the physical dimensions
transpose(data);
medVal = median(median(data));
transpose(data);
if medVal > 100,
    physdim = 'uV';
elseif medVal > 0.5,
    physdim = 'mV';
else
    physdim = 'V';
end

verboseLabel = globals.get.VerboseLabel;
if isempty(verboseLabel),
    verboseLabel = '(ecgpuwave) ';
end

% Create a temporary directory under the home dir. This is VERY
% important because it seems that the HRV toolkit creates temporary
% files with fixed names. Thus we need to isolate completely each run
% of get_hrv
recName = DataHash(tempname);
recName = recName(1:14);

session.subsession(recName);
edfFileName     = catfile(session.instance.Folder, [recName '.edf']);

% Write input data to temporary EDF file
if verbose,
    fprintf([verboseLabel 'Writing ECG data to temporary EDF file...   ']);
end
write(edfFileName, [], data, 'Verbose', 2*verbose, 'SamplingRate', sr, ...
    'PhysDim', physdim);
if verbose, fprintf('[done]\n\n'); end

try  
   
    % Convert EDF file to MIT format    
    if verbose,
        fprintf([verboseLabel 'Converting EDF file to MIT format ...']);
    end
    cmd = sprintf('cd %s %s edf2mit -i %s.edf -r %s', ...
        session.instance.Folder, CMD_SEP, recName, recName);
    system(cmd); 
    if verbose, fprintf('[done]\n\n'); end
    
    
    % Detect QRS complexes using FMRIB
    if verbose,
        fprintf([verboseLabel 'Detecting QRS complexes using FMRIB ...']);
    end
    peaks = my_fmrib_qrsdetect(data(:,:), sr, false);
    annotFile = catfile(session.instance.Folder, [recName '.txt']);
    ecg_annotate.write_qrs_annot(annotFile, peaks, sr);
    if verbose, fprintf('[done]\n\n'); end
    
    % Convert annotation file to MIT format
    if verbose,
        fprintf([verboseLabel 'Converting %s.txt --> %s.qrs ...']);
    end
    cmd = sprintf('cd %s %s wrann -r %s -a qrs < %s.txt', ...
        session.instance.Folder, CMD_SEP, recName, recName);
    system(cmd);
    if verbose, fprintf('[done]\n\n'); end
 
    %% ecgpuwave
    if verbose,
        fprintf([verboseLabel 'Running ecgpuwave ...']);
    end
    info = ecgpuwave.limits(...
        session.instance.Folder, ...
        session.instance.Folder, ...
        session.instance.Folder, ...
        recName, ...
        'qrs', ...
        0, ...
        0);
    
    %% Conversion to TXT on the VM
    annFileName = [recName, '.txt'];
    cmd = sprintf('cd ~/%s ; rdann -r %s -a ecgpuwave > %s', recName, ...
        recName, annFileName);
    send_ssh_command(url, cmd, usr, pw, MAX_TRIES, PAUSE_INTERVAL);
    if verbose, fprintf('[done]\n\n'); end
    
    %% Downloading text annotations from VM
    if verbose,
        fprintf([verboseLabel 'Downloading annotations (%s)...'], ...
            annFileName);
    end
    source = sprintf('ecgpuwave@%s:~/%s/%s', url, recName, annFileName);
    target = catfile(tmpPath, annFileName);
    if ispc,
        cmd = sprintf('pscp -pw ecgpuwave %s %s', source, target);
    else
        cmd =  sprintf('sshpass -p ''ecgpuwave'' scp -o "%s" %s %s', ...
            'StrictHostKeyChecking no', source, target);
    end
    system(cmd);
    if verbose, fprintf('[done]\n\n'); end
    
    %% Compute the HRV features for each experimental condition
    if verbose,
        fprintf([verboseLabel 'Computing HRV features at %s...'], url);
    end
    sel = get_config(obj, 'EventSelector');
    
    if isempty(sel),   
        hrvFile = catfile(tmpPath, [recName '.hrv']);
        % Extract HRV features
        cmd = sprintf('cd %s ; get_hrv -M %s ecgpuwave > %s.hrv', ...
            recName, recName, recName);
        send_ssh_command(url, cmd, usr, pw, MAX_TRIES, PAUSE_INTERVAL);
        
        % Download the HRV features file
        source = sprintf('ecgpuwave@%s:~/%s/%s', url, recName, ...
            [recName '.hrv']);        
        if ispc,
            cmd = sprintf('pscp -pw ecgpuwave %s %s', source, hrvFile);
        else
            cmd =  sprintf('sshpass -p ''ecgpuwave'' scp -o "%s" %s %s', ...
                'StrictHostKeyChecking no', source, hrvFile);
        end
        system(cmd);
        
        hrvInfo = io.wfdb.hrv.read(hrvFile);        
        
    else
        hrvInfo = cell(1, numel(sel));
        ev = get_event(data);
        for i = 1:numel(sel)
            
            hrvFile = catfile(tmpPath, [recName '_' num2str(i) '.hrv']);
           
            thisEv = select(sel{i}, ev);
            
            if isempty(thisEv), continue; end
            
            % Create recName_i with the RR intervals
            for j = 1:numel(thisEv)
               
                first = get_sample(thisEv(j)) + get_offset(thisEv(j));
                last = get_sample(thisEv(j)) + get_duration(thisEv(j)) - 1;
                
                if (last - first) < data.SamplingRate*2,
                    error('Events have too short duration');
                end
                
                % Create RR time series
                %cmd = sprintf('rm %s_%d.rr', recName, i);
                %send_ssh_command(url, cmd, usr, pw, MAX_TRIES, PAUSE_INTERVAL);     
                cmd = sprintf(...
                    ['cd ~/%s ; ann2rr -r %s -a ecgpuwave -i s -f s%d ' ...
                    '-t s%d >> %s_%d.rr'], ...
                    recName, recName, first, last, recName, i);
                
                send_ssh_command(url, cmd, usr, pw, MAX_TRIES, PAUSE_INTERVAL);          
                
            end
            
            % Get HRV statistics for this group/condition
            cmd = sprintf('cd ~/%s ; get_hrv -M -R %s_%d.rr > %s_%d.hrv', ...
                recName, recName, i, recName, i);
            send_ssh_command(url, cmd, usr, pw, MAX_TRIES, PAUSE_INTERVAL);    
            
            % Download the HRV features file
            source = sprintf('ecgpuwave@%s:~/%s/%s_%d.hrv', url, ...
                recName, recName, i);
            if ispc,
                cmd = sprintf('pscp -pw ecgpuwave %s %s', source, hrvFile);
            else
                cmd =  sprintf('sshpass -p ''ecgpuwave'' scp -o "%s" %s %s', ...
                    'StrictHostKeyChecking no', source, hrvFile);
            end
            system(cmd);
            
            hrvInfo{i} = io.wfdb.hrv.read(hrvFile);            
            
        end

    end
    
    if verbose, fprintf('[done]\n\n'); end
    
catch ME
    
    % Clean up and shut down the VM
    cmd = sprintf('rm -rf ~/%s*', recName);
    if ispc,
        cmd = sprintf('plink -pw ecgpuwave ecgpuwave@%s "%s"', url, cmd);
    else
        cmd = sprintf(['sshpass -p ''ecgpuwave'' ssh -o "%s" ' ...
            'ecgpuwave@%s "%s"'], 'StrictHostKeyChecking no', url, cmd);
    end
    system(cmd);
    % Do not shutdown the VM! Consider the case of multiple jobs running in
    % parallel which share a single VM instance. The user has to stop the
    % VM when he/she is done.
    %[~, ~] = system('VboxManage controlvm ecgpuwave acpipowerbutton');
    rethrow(ME);
    
end

% Extract annotations info
info = io.wfdb.annotations.read(catfile(tmpPath, annFileName));
delete(catfile(tmpPath, annFileName));


end