function test_suite = test_bids_query %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_query_exclude_entity()

  pth_bids_example = get_test_data_dir();
      
  BIDS = bids.layout(fullfile(pth_bids_example, 'ds000246'));

  filter = struct('sub', '0001');
  assertEqual(bids.query(BIDS, 'modalities', filter), {'anat', 'meg'});
  
  filter = struct('sub', '0001', 'suffix', 'photo');
  assertEqual(bids.query(BIDS, 'modalities', filter), {'meg'});
  
  filter = struct('sub', '0001', 'acq', 'NAS');
  assertEqual(bids.query(BIDS, 'modalities', filter), {'meg'});
  
  filter = struct('sub', '0001', 'acq', '');
  assertEqual(bids.query(BIDS, 'suffixes', filter), {'T1w', 'channels', 'headshape', 'meg'});

end

function test_query_basic()

  pth_bids_example = get_test_data_dir();

  BIDS = bids.layout(fullfile(pth_bids_example, 'pet005'));

  tasks = {'eyes'};
  assertEqual(bids.query(BIDS, 'tasks'), tasks);

  assert(isempty(bids.query(BIDS, 'runs', 'suffix', 'T1w')));

  sessions = {'baseline', 'intervention'};
  assertEqual(bids.query(BIDS, 'sessions'), sessions);
  assertEqual(bids.query(BIDS, 'sessions', 'suffix', 'pet'), sessions);

end

function test_query_data_filter()

  pth_bids_example = get_test_data_dir();

  BIDS = bids.layout(fullfile(pth_bids_example, 'pet005'));

  % make sure that query can work with filter
  filters = {'sub', {'01'}; ...
             'task', {'eyes'}; ...
             'ses', 'intervention'};

  files_cell_filter = bids.query(BIDS, 'data', filters);
  assertEqual(size(files_cell_filter, 1), 2);

  filters = struct('sub', '01', ...
                   'suffix', 'pet');
  filters.ses = {'baseline', 'intervention'};

  files_struct_filter = bids.query(BIDS, 'data', filters);
  assertEqual(size(files_struct_filter, 1), 2);

end

function test_query_extension()

  pth_bids_example = get_test_data_dir();

  BIDS = bids.layout(fullfile(pth_bids_example, 'qmri_tb1tfl'));

  extensions = bids.query(BIDS, 'extensions');

  data = bids.query(BIDS, 'data', ...
                    'sub', '01', ...
                    'extension', '.nii.gz', ...
                    'suffix', 'TB1TFL');
  assertEqual(size(data, 1), 2);

  data = bids.query(BIDS, 'data', ...
                    'sub', '01', ...
                    'extension', '.json');
  assertEqual(size(data, 1), 0);

end

function test_query_metadata()

  pth_bids_example = get_test_data_dir();

  BIDS = bids.layout(fullfile(pth_bids_example, 'qmri_tb1tfl'));

  md = bids.query(BIDS, 'metadata', ...
                  'sub', '01', ...
                  'acq', 'anat', ...
                  'suffix', 'TB1TFL');
  assert(isstruct(md) & isfield(md, 'RepetitionTime') & isfield(md, 'SequenceName'));
  assert(strcmp(md.RepetitionTime, '6.8'));
  assert(strcmp(md.SequenceName, 'tfl_b1_map'));

end

function test_query_modalities()

  pth_bids_example = get_test_data_dir();

  BIDS = bids.layout(fullfile(pth_bids_example, 'pet002'));

  modalities = {'anat', 'pet'};

  assertEqual(bids.query(BIDS, 'modalities'), modalities);
  assertEqual(bids.query(BIDS, 'modalities', 'sub', '01'), modalities);
  assertEqual(bids.query(BIDS, 'modalities', 'sub', '01', 'ses', 'rescan'), modalities);

  % this now fails on octave 4.2.2 but not on Matlab
  %
  % bids.query(BIDS, 'modalities', 'sub', '01', 'ses', '2')
  %
  % ans =
  % {
  %   [1,1] = anat
  %   [1,2] = fmap
  %   [1,3] = func
  % }
  %
  % when it should return

  % assertEqual(bids.query(BIDS, 'modalities', 'sub', '01', 'ses', '2'), mods(2:3)));

end

function test_query_subjects()

  pth_bids_example = get_test_data_dir();

  BIDS = bids.layout(fullfile(pth_bids_example, 'ieeg_visual'));

  subjs = arrayfun(@(x) sprintf('%02d', x), 1:2, 'UniformOutput', false);
  assertEqual(bids.query(BIDS, 'subjects'), subjs);

end

function test_query_sessions()

  pth_bids_example = get_test_data_dir();

  BIDS = bids.layout(fullfile(pth_bids_example, 'synthetic'));
  sessions = {'01', '02'};
  assertEqual(bids.query(BIDS, 'sessions'), sessions);
  assertEqual(bids.query(BIDS, 'sessions', 'sub', '02'), sessions);

  BIDS = bids.layout(fullfile(pth_bids_example, 'qmri_tb1tfl'));

  assert(isempty(bids.query(BIDS, 'sessions')));

end

function test_query_suffixes()

  pth_bids_example = get_test_data_dir();

  BIDS = bids.layout(fullfile(pth_bids_example, 'pet002'));

  suffixes = {'T1w'    'pet'};
  assertEqual(bids.query(BIDS, 'suffixes'), suffixes);

end

function test_query_sessions_tsv()

  pth_bids_example = get_test_data_dir();

  BIDS = bids.layout(fullfile(pth_bids_example, '7t_trt'));

  assert(~isempty(BIDS.subjects(1).sess));
  assert(~isempty(BIDS.subjects(1).scans));

end

function test_query_scans_tsv()

  pth_bids_example = get_test_data_dir();

  BIDS = bids.layout(fullfile(pth_bids_example, 'ds009'));

  assert(~isempty(BIDS.subjects(1).scans));

end
