function surfzlim(source,event)
        val = 51 - source.Value;
        % For R2014a and earlier:
        % val = 51 - get(source,'Value')
        set(source,'Tag','val');
    end