function [DATA] = clipFirstMilliSeconds(DATA, timecol, millisec)
    %Function [DATA] = clipFirstMilliSeconds(DATA, timecol, millisec)
    %
    % Returns the first millisec milliseconds of DATA-matrix.

    rowcount = rowCount(DATA);
    colcount = columnCount(DATA);

    millisec_at_start = getValueGAL(DATA, 1, timecol);

    if millisec <= 0
        % if milliseconds zero or below, return empty data
        DATA = formatDataGAL(DATA);
    elseif millisec_at_start + millisec < getValueGAL(DATA, rowcount, ...
                                                      timecol)
        % if there are more rows than the ms limit
        cutrow = find(getColumnGAL(DATA, timecol) < ...
                      millisec_at_start + millisec, 1, 'last');  
        % put all the columns after numrows as blank
        for i=1:colcount
            DATA{i}(cutrow+1:rowcount) = [];
        end
    else
        disp(['  The millisecond-limit surpasses timevalues' ...
              ' found in data. Not clipping anything.']);
    end