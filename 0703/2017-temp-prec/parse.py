months = list(range(1, 13))

for month in months:
    # Read input
    inputfile = './raw/2017_%02d.csv' % month
    f_input = open(inputfile, encoding='euc-kr', mode='r')
    lines = f_input.readlines()
    f_input.close()

    # Parse and save
    outputfile = './utf8/2017_%02d_utf8.csv' % month
    f_output = open(outputfile, encoding='utf-8', mode='w')
    f_output.write('지점번호,지점,일시,기온,강수량\n')
    for th, line in enumerate(lines):
        if th < 7:
            continue
        f_output.write(line[:-2] + '\n')
    f_output.close()

    # Parse and save
    outputfile = './euckr/2017_%02d_euckr.csv' % month
    f_output = open(outputfile, encoding='euc-kr', mode='w')
    f_output.write('지점번호,지점,일시,기온,강수량\n')
    for th, line in enumerate(lines):
        if th < 7:
            continue
        f_output.write(line)
    f_output.close()
