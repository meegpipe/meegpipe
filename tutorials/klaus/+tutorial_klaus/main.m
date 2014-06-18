% main

FILE = 'NBT.S0021.090205.EOR1.set';

if ~exist(FILE, 'file'),
    url = 'https://dl.dropboxusercontent.com/u/4479286/meegpipe/NBT.S0021.090205.EOR1.zip';
    urlwrite(url, 'NBT.S0021.090205.EOR1.zip');
    unzip('NBT.S0021.090205.EOR1.zip', pwd);
end

myPipe = tutorial_klaus.create_pipeline;

run(myPipe, FILE);