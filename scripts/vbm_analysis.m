%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Voxel-Based Morphometry Analysis (CAT12 + SPM)
% Author: Noelia Calvo, PhD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; clc;
rng(42);

%% Load configuration
run('../config/config.m');

%% Add toolbox paths
addpath(cat12_path);
addpath(spm_path);

%% Collect subject files
group1_files = spm_select('FPList', group1_dir, '^.*\.nii$');
group2_files = spm_select('FPList', group2_dir, '^.*\.nii$');
group3_files = spm_select('FPList', group3_dir, '^.*\.nii$');

all_subjects = char(group1_files, group2_files, group3_files);

%% Design matrix labels
group_labels = [
    ones(size(group1_files,1),1);
    2*ones(size(group2_files,1),1);
    3*ones(size(group3_files,1),1)
];

%% Preprocessing batch
matlabbatch = {};

matlabbatch{1}.spm.spatial.preproc.channel.vols = cellstr(all_subjects);
matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;

%% Smoothing
matlabbatch{2}.spm.spatial.smooth.data = cellstr(all_subjects);
matlabbatch{2}.spm.spatial.smooth.fwhm = [8 8 8];

%% Factorial design (ANOVA)
matlabbatch{3}.spm.stats.factorial_design.dir = {output_dir};

matlabbatch{3}.spm.stats.factorial_design.des.anova.icell(1).scans = cellstr(group1_files);
matlabbatch{3}.spm.stats.factorial_design.des.anova.icell(2).scans = cellstr(group2_files);
matlabbatch{3}.spm.stats.factorial_design.des.anova.icell(3).scans = cellstr(group3_files);

%% Model estimation
matlabbatch{4}.spm.stats.fmri_est.spmmat = {fullfile(output_dir,'SPM.mat')};

%% Contrasts
matlabbatch{5}.spm.stats.con.spmmat = {fullfile(output_dir,'SPM.mat')};

matlabbatch{5}.spm.stats.con.consess{1}.tcon.name = 'Group1 > Group2';
matlabbatch{5}.spm.stats.con.consess{1}.tcon.weights = [1 -1 0];

matlabbatch{5}.spm.stats.con.consess{2}.tcon.name = 'Group2 > Group3';
matlabbatch{5}.spm.stats.con.consess{2}.tcon.weights = [0 1 -1];

matlabbatch{5}.spm.stats.con.consess{3}.tcon.name = 'Group1 > Group3';
matlabbatch{5}.spm.stats.con.consess{3}.tcon.weights = [1 0 -1];

%% Run pipeline
spm_jobman('run', matlabbatch);

disp('VBM analysis completed successfully.');