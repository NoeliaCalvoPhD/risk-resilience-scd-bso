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
group1_files = spm_select('FPList', group1_dir, '^.*\.nii$'); % AMC
group2_files = spm_select('FPList', group2_dir, '^.*\.nii$'); % BRCA-C
group3_files = spm_select('FPList', group3_dir, '^.*\.nii$'); % BSO
group4_files = spm_select('FPList', group4_dir, '^.*\.nii$'); % SM

all_subjects = char(group1_files, group2_files, group3_files, group4_files);

%% Design matrix labels
group_labels = [
    ones(size(group1_files,1),1);
    2*ones(size(group2_files,1),1);
    3*ones(size(group3_files,1),1);
    4*ones(size(group4_files,1),1)
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

matlabbatch{3}.spm.stats.factorial_design.des.anova.icell(1).scans = cellstr(group1_files); % AMC
matlabbatch{3}.spm.stats.factorial_design.des.anova.icell(2).scans = cellstr(group2_files); % BRCA-C
matlabbatch{3}.spm.stats.factorial_design.des.anova.icell(3).scans = cellstr(group3_files); % BSO
matlabbatch{3}.spm.stats.factorial_design.des.anova.icell(4).scans = cellstr(group4_files); % SM

%% Model estimation
matlabbatch{4}.spm.stats.fmri_est.spmmat = {fullfile(output_dir,'SPM.mat')};

%% Contrasts
matlabbatch{5}.spm.stats.con.spmmat = {fullfile(output_dir,'SPM.mat')};

% AMC > BRCA-C
matlabbatch{5}.spm.stats.con.consess{1}.tcon.name = 'AMC > BRCA-C';
matlabbatch{5}.spm.stats.con.consess{1}.tcon.weights = [1 -1 0 0];

% BRCA-C > BSO
matlabbatch{5}.spm.stats.con.consess{2}.tcon.name = 'BRCA-C > BSO';
matlabbatch{5}.spm.stats.con.consess{2}.tcon.weights = [0 1 -1 0];

% AMC > BSO
matlabbatch{5}.spm.stats.con.consess{3}.tcon.name = 'AMC > BSO';
matlabbatch{5}.spm.stats.con.consess{3}.tcon.weights = [1 0 -1 0];

% SM > AMC
matlabbatch{5}.spm.stats.con.consess{4}.tcon.name = 'SM > AMC';
matlabbatch{5}.spm.stats.con.consess{4}.tcon.weights = [-1 0 0 1];

% SM > BRCA-C
matlabbatch{5}.spm.stats.con.consess{5}.tcon.name = 'SM > BRCA-C';
matlabbatch{5}.spm.stats.con.consess{5}.tcon.weights = [0 -1 0 1];

% SM > BSO
matlabbatch{5}.spm.stats.con.consess{6}.tcon.name = 'SM > BSO';
matlabbatch{5}.spm.stats.con.consess{6}.tcon.weights = [0 0 -1 1];

%% Run pipeline
spm_jobman('run', matlabbatch);

disp('VBM analysis completed successfully.');
