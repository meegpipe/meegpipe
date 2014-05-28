% MAIN - Performs all pre-preprocessing steps from the raw data

fileList = {...
    'export_26-11_calibratie.Poly5' ...
    };

run(grunberg.preprocess_pipeline, fileList{:});