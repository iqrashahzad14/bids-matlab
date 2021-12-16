function diagnostic_table = diagnostic(varargin)
    %
    %
    %
    %
    % (C) Copyright 2021 BIDS-MATLAB developers

    default_BIDS = pwd;
    default_schema = true;
    default_filter = struct();
    default_split = {''};
    default_output_path = '';

    p = inputParser;

    charOrStruct = @(x) ischar(x) || isstruct(x);

    addOptional(p, 'BIDS', default_BIDS, charOrStruct);
    addParameter(p, 'use_schema', default_schema);
    addParameter(p, 'output_path', default_output_path, @ischar);
    addParameter(p, 'filter', default_filter, @isstruct);
    addParameter(p, 'split_by', default_split, @iscell);

    parse(p, varargin{:});

    BIDS = bids.layout(p.Results.BIDS);

    filter = p.Results.filter;

    subjects = bids.query(BIDS, 'subjects', filter);

    modalities = bids.query(BIDS, 'modalities', filter);

    headers = {};
    for i_modality = 1:numel(modalities)

        if ismember('task', p.Results.split_by) && ...
            ismember(modalities(i_modality), {'func', 'eeg', 'meg', 'ieeg', 'pet', 'beh'})

            this_filter = filter;
            this_filter.modality = modalities(i_modality);
            tasks = bids.query(BIDS, 'tasks', this_filter);

            for i_task = 1:numel(tasks)
                headers{end + 1} = struct('modality', modalities(i_modality), ...
                    'task', tasks(i_task));
            end

        else
            headers{end + 1} = struct('modality', modalities(i_modality));

        end

    end

    diagnostic_table = nan(numel(subjects), numel(modalities));
%     events_table = nan(numel(subjects), numel(tasks));

    row = 1;

    for i_sub = 1:numel(subjects)

        this_filter = get_clean_filter(filter, subjects{i_sub});

        sessions = bids.query(BIDS, 'sessions', this_filter);
        if isempty(sessions)
            sessions = {''};
        end

        for i_sess = 1:numel(sessions)

            this_filter = get_clean_filter(filter, subjects{i_sub});
            this_filter.ses = sessions{i_sess};

            files = bids.query(BIDS, 'data', this_filter);

            if size(files, 1) == 0
                continue
            end

            for i_col = 1:numel(headers)

                this_filter = get_clean_filter(filter, subjects{i_sub}, sessions{i_sess});
                this_filter.modality = headers{i_col}.modality;
                if isfield(headers{i_col}, 'task')
                    this_filter.task = headers{i_col}.task;
                end

                files = bids.query(BIDS, 'data', this_filter);

                diagnostic_table(row, i_col) = size(files, 1);

            end

            sub_ses{row} = ['sub-' this_filter.sub];
            if ~isempty(this_filter.ses)
                sub_ses{row} = ['sub-' this_filter.sub ' ses-' this_filter.ses];
            end

            row = row + 1;

        end

    end

    fig_name = BIDS.description.Name;
    if isempty(fig_name) || strcmp(fig_name, ' ')
        fig_name = 'this_dataset';
    end
    if ~cellfun('isempty', p.Results.split_by)
        fig_name = [fig_name ' - split_by ' strjoin(p.Results.split_by, '-')];
    end


    plot_diagnostic_table(diagnostic_table, headers, sub_ses, ...
        strrep(fig_name, '_', ' '))

    if ~isempty(p.Results.output_path)
        if exist(p.Results.output_path, 'dir')
            bids.util.mkdir(p.Results.output_path);
            print(fig_name, '-dpng')
        end
    end

end

function this_filter = get_clean_filter(filter, sub, ses)
    this_filter = filter;
    this_filter.sub = sub;
    if nargin > 2
        this_filter.ses = ses;
    end
end

function plot_diagnostic_table(diagnostic_table, headers, yticklabel, fig_name)

    % prepare x tick labels
    for col = 1:numel(headers)
        xticklabel{col} = [headers{col}.modality];
        if isfield(headers{col}, 'task')
            xticklabel{col} = sprintf('%s - task: %s', headers{col}.modality,  headers{col}.task);
        end
        if length(xticklabel{col}) > 43
            xticklabel{col} = [xticklabel{col}(1:40) '...'];
        end
    end

    nb_rows = size(diagnostic_table, 1);
    nb_cols = size(diagnostic_table, 2);

    figure('name', 'diagnostic_table', 'position', [1000 1000 50 + 350 * nb_cols 50 + 100 * nb_rows]);

    colormap('gray');

    imagesc(diagnostic_table, [0, max(diagnostic_table(:))]);

    % x axis
    set(gca, 'XAxisLocation', 'top', ...
        'xTick', 1:nb_cols, ...
        'xTickLabel', xticklabel, ...
        'TickLength', [0.001 0.001]);

    if any(cellfun('length', xticklabel) > 40)
        set(gca, ...
            'xTick', (1:nb_cols) - 0.25, ...
            'XTickLabelRotation', 25);
    end

    % y axis
    set(gca, 'yTick', 1:nb_rows);
    if nb_rows < 50
        set(gca, 'yTick', 1:nb_rows, 'yTickLabel', yticklabel);
    end

    % plot actual values if there are not too many
    if numel(diagnostic_table) < 600
        for col = 1:nb_cols
            for row = 1:nb_rows
                t = text(col, row, sprintf('%i', diagnostic_table(row, col)));
                if diagnostic_table(row, col) == 0
                    set(t, 'Color', 'red');
                end
            end
        end
    end

    colorbar();

    title(fig_name);

end
