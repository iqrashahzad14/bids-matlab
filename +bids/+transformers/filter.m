function data = filter(transformer, data)
  %
  % Subsets rows using a boolean expression.
  %
  %
  % **JSON EXAMPLE**:
  %
  % .. code-block:: json
  %
  %     {
  %       "Name": "Filter",
  %       "Input": "sex",
  %       "Query": "age > 20"
  %     }
  %
  %
  % Arguments:
  %
  % :param Input: **mandatory**. The name(s) of the variable(s) to operate on.
  % :type  Input: string or array
  %
  % :param Query: **mandatory**. Boolean expression used to filter
  % :type  Query: string
  %
  % Supports:
  %
  % - ``>``, ``<``, ``>=``, ``<=``, ``==`` for numeric values
  % - ``==`` for string operation (case sensitive)
  %
  % :param Output: optional. The optional column names to write out to.
  % :type  Output: string or array
  %
  % By default, computation is done in-place (i.e., input columnise overwritten).
  % If provided, the number of values must exactly match the number of input values,
  % and the order will be mapped 1-to-1.
  %
  %
  % **CODE EXAMPLE**::
  %
  %   TODO
  %
  %
  % (C) Copyright 2022 BIDS-MATLAB developers

  % TODO
  % - By(str; optional): Name of column to group filter operation by

  input = bids.transformers.get_input(transformer, data);
  output = bids.transformers.get_output(transformer, data);

  [left, query_type, right] = bids.transformers.get_query(transformer);
  bids.transformers.check_field(left, data, 'query', false);

  % identify rows
  if iscellstr(data.(left))

    if ismember(query_type, {'>', '<', '>=', '<='})
      msg = sprtinf(['Types "%s" are not supported for queries on string\n'...
                     'in query %s'], ...
                    {'>, <, >=, <='}, ...
                    query);
      bids.internal.error_handling(mfilename(), ...
                                   'unsupportedQueryType', ...
                                   msg, ...
                                   false);

    end

    idx = strcmp(data.(left), right);

  elseif isnumeric(data.(left))

    right = str2num(right);

    switch query_type

      case '=='
        idx = data.(left) == right;

      case '>'
        idx = data.(left) > right;

      case '<'
        idx = data.(left) < right;

      case '>='
        idx = data.(left) >= right;

      case '<='
        idx = data.(left) <= right;

    end

  end

  % filter rows of all inputs
  for i = 1:numel(input)

    clear tmp;

    if iscellstr(data.(input{i}))

      tmp(idx, 1) = data.(input{i})(idx);

      tmp(~idx, 1) = repmat({nan}, sum(~idx), 1);

    elseif isnumeric(data.(input{i}))

      tmp(idx, 1) = data.(left)(idx);

      if iscellstr(tmp)
        tmp(~idx, 1) = repmat({nan}, sum(~idx), 1);
      else
        tmp(~idx, 1) = nan;
      end

    end

    data.(output{i}) = tmp;

  end

end
