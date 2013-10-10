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
import misc.has_pscp;
import misc.has_plink;
import misc.has_vbox;
import misc.has_ssh;
import datahash.DataHash;
import misc.send_ssh_command;
import misc.system;

MAX_TRIES       = 10;
PAUSE_INTERVAL  = 25;

verbose = is_verbose(obj);

vmURL = get_config(obj, 'VMUrl');

% Username and password for the remove VM
usr = meegpipe.get_config('node-ecg_annotate', 'vm-usr');
pw = meegpipe.get_config('node-ecg_annotate', 'vm-pw');

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


if nargin < 2 || isempty(sr),
    error('The data sampling rate must be provided');
end

if ~has_vbox,
    error('Dependency ''Virtual Box'' is missing.');
end

if ispc && (~has_pscp || ~has_plink),
    error('Dependency ''PuttY'' is missing');
elseif ~ispc && ~has_ssh
    error('Dependency ''ssh'' is missing');
end    

verboseLabel = globals.get.VerboseLabel;
if isempty(verboseLabel),
    verboseLabel = '(ecgpuwave) ';
end

edfFileName   = tempname;
[~, name]  = fileparts(edfFileName);
tmpPath = pset.session.instance.Folder;
edfFileName   = catfile(tmpPath, [name '.edf']);

% Write input data to temporary EDF file
if verbose,
    fprintf([verboseLabel 'Writing ECG data to temporary EDF file...   ']);
end
write(edfFileName, [], data, 'Verbose', 2*verbose, 'SamplingRate', sr, ...
    'PhysDim', physdim);
if verbose, fprintf('[done]\n\n'); end

% Start the ecgpuwave VM
if isempty(vmURL),
    [~, msg] = system('VBoxManage startvm ecgpuwave');
    
    if ~isempty(strfind(msg, 'VBOX_E_OBJECT_NOT_FOUND')),
        error('Unable to start ecgpuwave VM');
    end
    
    if isempty(strfind(msg, 'VBOX_E_INVALID_OBJECT_STATE')),
        % If the machine is not running already, start it!
        if verbose,
            fprintf([verboseLabel 'Starting ecgpuwave VM...']);
        end
        vm_wait = meegpipe.get_config('node-ecg_annotate', 'vm-wait');
        if isempty(vm_wait),
            vm_wait = 7;
        else
            vm_wait = min(40, double(vm_wait));
        end
        pause(vm_wait);
    end
    
    cmd = ['VBoxManage guestproperty get ecgpuwave ' ...
        '"/VirtualBox/GuestInfo/Net/0/V4/IP"'];
    [~, msg] = system(cmd);
    url = regexprep(msg, '[^\d]*(\d+\.\d+\.\d+\.\d+)[^\d]*', '$1');
    if isempty(url),
        error('The URL of the ecgpuwave VM is unknown');
    end
    if verbose,
        fprintf('[done]\n\n');
    end
else
    url = vmURL;
end


try
    recName = DataHash(tempname);
    recName = recName(1:14);
    
    % Create a temporary directory under the home dir. This is VERY
    % important because it seems that the HRV toolkit creates temporary
    % files with fixed names. Thus we need to isolate completely each run
    % of get_hrv
    if verbose,
        fprintf([verboseLabel 'Creating ~/%s on %s...'], ...
            recName, url);
    end
    cmd = sprintf('mkdir ~/%s', recName);
    send_ssh_command(url, cmd, usr, pw, MAX_TRIES, PAUSE_INTERVAL);   
    if verbose, fprintf('[done]\n\n'); end
    
    %% Transferring files to VM
    if verbose,
        fprintf([verboseLabel 'Transferring EDF file to %s...'], ...
            url);
    end
 
    
    if ispc,       
        cmd1 = sprintf('pscp -pw ecgpuwave %s ecgpuwave@%s:~/%s/%s', ...
            edfFileName, url, recName, [recName '.edf']);       
    else
        % error('Not implemented this OS!');
        cmd1 =  sprintf(['sshpass -p ''ecgpuwave'' scp -o "%s" %s ' ...
            'ecgpuwave@%s:~/%s/%s'], 'StrictHostKeyChecking no', ...
            edfFileName, url, recName, [recName '.edf']);        
    end
    
    system(cmd1);

    if verbose, fprintf('[done]\n\n'); end
    
    % Convert EDF file to MIT format    
    if verbose,
        fprintf([verboseLabel 'Converting EDF file to MIT at %s'], url);
    end
    cmd = sprintf('cd ~/%s ; edf2mit -i %s.edf -r %s', recName, recName, ...
        recName);
    send_ssh_command(url, cmd, usr, pw, MAX_TRIES, PAUSE_INTERVAL);    
    if verbose, fprintf('[done]\n\n'); end    
 
    %% ecgpuwave on the VM
    if verbose,
        fprintf([verboseLabel 'Running ecgpuwave at %s...'], url);
    end
    cmd = sprintf('cd ~/%s ; ecgpuwave -r %s -a ecgpuwave', recName, ...
        recName);
    send_ssh_command(url, cmd, usr, pw, MAX_TRIES, PAUSE_INTERVAL);
    
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
        cmd = sprintf('cd ~/%s ; get_hrv -M %s ecgpuwave > %s.hrv', ...
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
% [~, ~] = system('VboxManage controlvm ecgpuwave acpipowerbutton');

% Extract annotations info
info = io.wfdb.annotations.read(catfile(tmpPath, annFileName));
delete(catfile(tmpPath, annFileName));


end