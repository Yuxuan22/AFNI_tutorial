%% Moves all .nii files one folder up. Written to quickly do so for the resulting directories from r2agui 

dirs = dir; 
dirs = dirs(3:end);

for idir = 1:length(dirs)
    if length( dir( dirs( idir).name)) > 2
        cd( dirs(idir).name)
        system('mv *.nii ..')
        cd ..
    end
end
                           