subjects = {'sub-8107'
'sub-8108'
'sub-8109'
'sub-8110'
'sub-8111'
'sub-8112'
'sub-8113'
'sub-8114'
'sub-8115'
'sub-8116'
'sub-8117'
'sub-8118'
'sub-8119'
'sub-8120'
'sub-8121'
'sub-8122'
'sub-8123'
'sub-8124'
'sub-8125'
'sub-8126'
'sub-8127'
'sub-8128'
'sub-8129'
'sub-8130'
'sub-8131'
'sub-8132'
'sub-8133'
'sub-8134'
'sub-8135'};

for sub = 1:length(subjects)
    fid=fopen(['../derivatives_misq/' subjects{sub} '/timings/Phase_2_HHH.txt']);
    hhh = fscanf(fid, '%f*%f:%f');
    fclose(fid);
    
    fid=fopen(['../derivatives_misq/' subjects{sub} '/timings/Phase_2_LLL.txt']);
    lll = fscanf(fid, '%f*%f:%f');
    fclose(fid);
    
    onsetsBlock1 = [hhh([1,4,7],1); lll([1,4,7],1)];
    durationsBlock1 = [hhh([3,6,9],1); lll([3,6,9],1)];
    
    [onsetsBlock1Sorted, index] = sortrows(onsetsBlock1);
    durationsBlock1Sorted = durationsBlock1(index);
    
    onsetsBlock2 = [hhh([10,13,16],1); lll([10,13,16],1)];
    durationsBlock2 = [hhh([12,15,18],1); lll([12,15,18],1)];
    
    [onsetsBlock2Sorted, index] = sortrows(onsetsBlock2);
    durationsBlock2Sorted = durationsBlock2(index);
    
    mkdir(['../derivatives/' subjects{sub} '/timings/']);
    
    fid2 = fopen(['../derivatives/' subjects{sub} '/timings/Phase_2_HHH+LLL.txt'], 'w+');
    for i =1:6
        fprintf(fid2, '%4.2f*1:%4.2f ', onsetsBlock1Sorted(i), durationsBlock1Sorted(i));
    end
    fprintf(fid2, '\n');
    for i =1:6
        fprintf(fid2, '%4.2f*1:%4.2f ', onsetsBlock2Sorted(i), durationsBlock2Sorted(i));
    end
    fprintf(fid2, '\n');
    fclose(fid2);
end
