function save_figure(filename)
    %   Export the Current Figure to assets/filename as a PNG

    %   Input
    %   filename:	name of the PNG file to write inside assets

    %   Output
    %   none

    repoRoot = fileparts(fileparts(mfilename('fullpath')));
    assetsDir = fullfile(repoRoot, 'assets');
    if ~exist(assetsDir, 'dir')
        mkdir(assetsDir);
    end
    exportgraphics(gcf, fullfile(assetsDir, filename), 'Resolution', 150);
end
