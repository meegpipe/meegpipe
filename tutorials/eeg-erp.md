Tutorial: Processing an ERP hdEEG dataset
========

__IMPORTANT NOTE:__ This tutorial is still under preparation. 

This tutorial has been prepared for my colleagues at the 
[Netherlands Institute for Neuroscience][nin]. Nevertheless it should 
contain quite some useful information also for anybody aiming to 
use _meegpipe_ to clean high density EEG. 

[nin]: http://www.herseninstituut.knaw.nl
[erp]: http://en.wikipedia.org/wiki/Event-related_potential


## Dataset description

To be done: detailed description of the experimental paradigm

Unfortunately the data used in this tutorial is not freely
 available so only people working at the [Sleep&Cognition team][sc] of the 
[Netherlands Institute for Neuroscience][nin] will be able to reproduce 
this tutorial exactly. Some other tutorials do use publicly available 
data (e.g. the [MEG][meg-tutorial] tutorial).

## Symbolic links to the relevant data files

__NOTE:__ This section is relevant only if you are working at the 
somerengrid. 

[nin]: http://http://www.nin.knaw.nl/
[sc]: http://www.nin.knaw.nl/ResearchGroups/VanSomerenGroup/tabid/94/Default.aspx
[meg-tutorial]: https://github.com/germangh/meegpipe/blob/master/tutorials/meg-rs.md

Use the [somsds][somsds] scripts to generate links to the data files that 
you want to process. In our case we want to clean all __EEG__ files that 
were recorded while the subjects undertook an __auditory oddball__ task:

[somsds]: http://germangh.com/somsds

````bash
$ cd ~  # I assume this is your working dir
$ sosmds_link2rec ssmd --modality eeg --condition auob
````

The command above will generate a series of symbolic links under 
`~/ssmd` with pretty names and that point to the right raw data files 
(whose actual names may be quite ugly):

````bash
$ ls ~/ssmd 

ssmd_0128_eeg_auob_1.mff  ssmd_0138_eeg_auob_1.mff  ssmd_0148_eeg_auob_1.mff
ssmd_0128_eeg_auob_2.mff  ssmd_0138_eeg_auob_2.mff  ssmd_0148_eeg_auob_2.mff
...
````

See the documentation of the [somsds][somsds] scripts for more information 
on how to retrieve relevant data files from the repository of experimental 
recordings.


## Design your pipeline

Before anything else you need to decide what processing steps your pipeline 
will involve. Our datasets are hdEEG recordings (256 channels) sampled at
1KHz. The data has been acquired with a [Geodesic EEG System][egi]. A 
reasonable design for the processing pipeline would consist of the following 
stages:

1. Data import (from EGI's `.mff` proprietary data format).
2. Remove data mean.
3. Remove very low frequency data trends.
4. Downsample to 250 Hz.
5. Band pass filter (between 0.5 Hz and 40 Hz).
6. Reject bad data channels.
7. Reject bad data samples.
8. Re-referencing (average reference).
9. Remove cardiac artifact.
10. Remove ocular activity ([EOG][artifacts-phys] artifacts).
11. Remove muscle activity ([EMG][artifacts-phys] artifacts).
12. Reject bad epochs.
13. Interpolate bad channels
14. Calculate average ERPs in selected channels.

Obviously this is just a preliminary design. After testing it in the following 
steps we may decide to drop some of the processing nodes or to include new
ones. What we will almost surely do is to tune the parameters of every node so 
that the pipeline fits as well as possible the specific characteristics of our data.

[egi]: http://www.egi.com/research-division-research-products/eeg-systems
[artifacts-phys]: http://emedicine.medscape.com/article/1140247-overview#aw2aab6b3
[artifacts-extraphys]: http://emedicine.medscape.com/article/1140247-overview#aw2aab6b4

### In code

We are going to split our long and complex pipeline into three 
smaller, easier to handle pipelines.

### The basic pipeline

Let's start with a basic pipeline, defined as the first 6 stages of the 
pipeline outlined above:

````matlab
function myPipeline = basic_pipeline()

    import meegpipe.*;
    eval(alias_import('nodes'));
    import physioset.import.mff;
    import report.plotter.plotter;
    import meegpipe.node.bad_channels.criterion.xcorr.xcorr;

    % A node that imports .mff data
    myImportNode = physioset_import('Importer', mff);

    % A node that rejects channels using a variance-correlation criterion
    myCrit = var('Percentile', [7 93]);
    myBadChanNode =  bad_channels('Criterion', myCrit);

    % The data resampling node
    myResamplNode = resample('DownsampleBy', 4);

    % The band pass filter node
    myFilter = filter.bpfilt('Fp', [0.5 40]/125);
    myBpfiltNode = bpfilt('BpFilt', myFilter);

    % The other nodes will use the default configuration so we are ready
    % to build the pipeline:
    myPipeline = pipeline('NodeList', {...
        myImportNode, ...
        center, ...
        detrend, ...
        myResamplNode, ...
        myBpfiltNode, ...
        myBadChanNode, ...
        bad_samples, ...
        reref.avg ...
        }, ...
        ...
        'Name', 'Basic pipeline', ...
        'Save', true);
end
````

#### The artifact removal pipeline

We can now define a function `long_pipeline` that builds upon 
the basic pipeline and incorporates all processing nodes:

````matlab
function myPipeline = artifact_pipeline()

    import meegpipe.*;
    eval(alias_import('nodes'));
    import meegpipe.node.bss_regr.pwl;
    import meegpipe.node.bss_regr.ecg;
    import meegpipe.node.bss_regr.eog;
    import meegpipe.node.bss_regr.emg;

    % Node bss_regr is the swiss army knife node that we also use for 
    % removing ECG, EOG, and EMG artifacts. We just need to use the
    % correct default constructor so that the configuration of the bss_regr
    % node suits our specific needs:
    myPipeline = pipeline('NodeList', ...
        {...       
        ecg(250), ...
        eog(250), ...
        emg(250) ...
        }, ...
        ...
        'Name', 'Artifact pipeline', ...
        'Save', true);
end
````

Note that the last four nodes of the pipeline above are all of class 
`bss_regr`. They only differ from each other in their specific configuration. 
Indeed `bss_regr` is extremely configurable and you can be sure that the node
 produced by the default `pwl` constructor will behave very differently from the 
node produced by the `eog` constructor.


#### The analysis pipeline

This last pipeline will be defined as:

````matlab
function myPipeline = analysis_pipeline(evSelector)
    import meegpipe.*;
    eval(alias_import('nodes'));
    import physioset.event.class_selector;
    import meegpipe.node.bad_epochs.criterion.stat.stat;

	% This "event selector" object will select the events that are relevant
	% for ERP computation. We will see later why it is a good idea to have this
	% as an input argument to analysis_pipeline
    if nargin < 1 || isempty(evSelector),
        evSelector = class_selector('Type', 'stm+');
    end
	
	% A bad_epochs node will be used to reject noisy epochs before computing the ERP
	myCrit = stat(...
		'Statistic1', @(x) max(abs(x)), ...
		'Statistic2', @(x) max(x), ...
		'Percentile', [1 92]);
	myBadEpochsNode = bad_epochs(...
		'EventSelector', evSelector, ...
		'Criterion',     myCrit);
	
    % Build the ERP computation node
    myErpNode = erp(...
    'EventSelector',    evSelector, ...
    'Duration',         1.1, ...
    'Offset',           -0.1, ...
    'Baseline',         [-0.1 0], ...
    'PeakLatRange',     [0.3 0.6], ...
    'AvgWindow',        0.05, ...
    'MinMax',           'max', ...
    'Filter',           filter.ba(ones(1, 10)/10, 1), ...
    'Channels',         {'EEG 21$', 'EEG 81', 'EEG 101'});

    myPipeline = pipeline('NodeList', ...
        {...
            chan_interp, ... 
            myErpNode ...
        }, ...
        'Name', 'Analysis pipeline');

end
````

Note that we wrote `EEG 21$` in the definition of the channel 
sets to be used by node `erp` (parameter `Channels` above). The
reason is that each entry of the cell array assigned to `Channels`
is treated as [regular expression][regex-wiki]. If we would have 
written `EEG 21` instead then the first channel set would have 
contained channels EEG 21, _and_ EEG 210, EEG 211, ... EEG 219.

[regex-wiki]: http://en.wikipedia.org/wiki/Regular_expression

#### The global pipeline

We can now easily define the global pipeline as a pipeline whose nodes 
are the three pipelines that we defined above:

````matlab
function myPipeline = global_pipeline()

    import meegpipe.node.pipeline.pipeline;

    myPipeline = pipeline('NodeList', ...
        {basic_pipeline, artifact_pipeline, analysis_pipeline}, ...
        'Name', 'ssmd-erp pipeline');

end
````

Of course you could have defined the global pipeline in a single 
function but you should always try to break your pipelines into as many 
reusable components as possible. For instance, `basic_pipeline` is so 
generic that it can be easily used as a foundation for many other pipelines.

## Defining a custom event selector

The pipeline that we designed in the previous step has a flaw. It will 
create an ERP based all `stm+` stimuli. However, there are two types of
`stm+` stimuli: _deviant_ and _standard_. We can identify deviant `stm+`
stimuli using the `cel` meta-property of the `stm+` event. We say
meta-property because `cel` is not one of the built-in properties of
class [physioset.event.event][event-class].

[event-class]: https://github.com/germangh/matlab_physioset/blob/master/%2Bphysioset/%2Bevent/%40event/event.m

To complicate matters, the frequencies of standard and deviant stimuli
were swapped across participants. Thus, `cel=1` means standard for 
some subjects and deviant for others. Obviously, selecting the events we 
want cannot be done using some of the generic event selectors
included with _meegpipe_, such as the [class_selector][ev-class-sel] or
the [sample_selector][ev-sample-sel].

[ev-class-sel]: https://github.com/germangh/matlab_physioset/blob/master/%2Bphysioset/%2Bevent/class_selector.m
[ev-sample-sel]: https://github.com/germangh/matlab_physioset/blob/master/%2Bphysioset/%2Bevent/sample_selector.m

To define a custom event selector you will need to define a new 
[event selector class][ev-selector]:

[ev-selector]: https://github.com/germangh/matlab_physioset/blob/master/%2Bphysioset/%2Bevent/selector.m

````matlab
classdef custom_selector < physioset.event.selector
    
    properties
        CelValue = 1;
    end
    
    methods
        
        function [evArray, idx] = select(obj, evArray)
            
            selected = arrayfun(...
                @(x) strcmp(get(x, 'Type'), 'stm+') && ...
                (get_meta(x, 'cel') == obj.CelValue), evArray);
            
            evArray = evArray(selected);
            idx = find(selected);            
            
        end
        
        % Constructor
        function obj = custom_selector(celVal)
            
            if nargin < 1, return; end
           
            obj.CelVal = celVal;
            
        end
        
    end    
    
end
````

For subjects 128 and 134 deviants are identified by `cel=2`, while
for subjects 135 and 139 deviants have `cel=1`. So:

````matlab

import meegpipe.node.pipeline.pipeline;

myPipeA = pipeline('NodeList', ...
	{basic_pipeline, artifact_pipeline, analysis_pipeline(custom_selector(2))}, ...
	'Name', 'ssmd-erp-A');
	
myPipeB = pipeline('NodeList', ...
	{basic_pipeline, artifact_pipeline, analysis_pipeline(custom_selector(1))}, ...
	'Name', 'ssmd-erp-A');
	
run(myPipeA, 'ssmd_0128_eeg_auob_1.mff', 'ssmd_0134_eeg_auob_1.mff');
run(myPipeB, 'ssmd_0135_eeg_auob_1.mff', 'ssmd_0139_eeg_auob_1.mff');

````

If [Oracle Grid Engine][oge] is installed in your system, the code above 
will submit four processing jobs to the grid. Depending on the resources 
available on the grid, all jobs may run in parallel resulting in
considerable efficiency gains. 


[oge]: http://www.oracle.com/us/products/tools/oracle-grid-engine-075549.html


## Fine tuning the pipeline

Creating the pipeline was deceptively simple. That was because we used 
the default configurations for almost every node in the pipeline. However, 
EEG data is extremely heterogeneous (across EEG systems, tasks, subjects, 
or even recording sessions). Thus you should not be suprised if 
the two pipelines that we defined above end up doing a poor job, either
because they correct too little or because they overcorrect. 


### Inspecting the results



### Modifying pipeline configuration


## Processing 


## Fine tuning runtime parameters


## Export results