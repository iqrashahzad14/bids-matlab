function data = copy(transformer, data)
  %
  % Clones/copies each of the input columns to a new column with identical values
  % and a different name. Useful as a basis for subsequent transformations that need
  % to modify their input in-place.
  %
  %
  % **JSON EXAMPLE**:
  %
  % .. code-block:: json
  %
  %     {
  %       "Name": "Copy",
  %       "Input": [
  %           "sex_m",
  %           "age_gt_twenty"
  %       ],
  %       "Output": [
  %           "tmp_sex_m",
  %           "tmp_age_gt_twenty"
  %       ]
  %     }
  %
  %
  % Arguments:
  %
  % :param Input: **mandatory**.  Column names to copy.
  % :type  Input: string or array
  %
  % :param Output: optional. Names to copy the input columns to.
  %                          Must be same length as input, and columns are mapped one-to-one
  %                          from the input array to the output array.
  % :type Output: string or array
  %
  %
  % **CODE EXAMPLE**::
  %
  %   TODO
  %
  % (C) Copyright 2022 BIDS-MATLAB developers

  input = bids.transformers.get_input(transformer, data);
  output = bids.transformers.get_output(transformer, data);

  assert(numel(input) == numel(output));

  for i = 1:numel(input)
    data.(output{i}) = data.(input{i});
  end

end
