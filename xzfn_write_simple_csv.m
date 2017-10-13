function xzfn_write_simple_csv(outfile, header, thedata)
    cntrow = size(thedata,1);
    
    foutcsv = fopen(outfile,'w');
    fprintf(foutcsv, [header,'\n']);
    for i=1:cntrow
        fprintf(foutcsv,[num2str(thedata(i)),'\n']);
    end
    fclose(foutcsv);

end