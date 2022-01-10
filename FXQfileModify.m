function FXQfileModify( efile, datetime )
fd = fopen(efile, 'r+');
i=0;
while ~feof(fd)
    line = fgetl(fd);
    i=i+1;
    newline{i} = line;
    res = regexp(line, '^ScenarioEpoch', 'match');
    if ~isempty(res)
        newline{i} = sprintf('ScenarioEpoch           %s', datetime);
    end
end
fclose(fd);
fd = fopen(efile, 'w+');
for k=1:i
   fprintf(fd, '%s\r\n', newline{k}); 
end
fclose(fd);
end

