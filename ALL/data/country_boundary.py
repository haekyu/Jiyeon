f = open('cow.txt')
lines = f.readlines()
f.close()

f = open('country_info.csv', 'w')

for th, line in enumerate(lines):
    if th < 28:
        continue
    else:
        words = line.split(';')
        f.write(','.join(words))
f.close()

f = open('country_boundary.csv', 'w')
header = ['ISO2', 'ISO3', 'Name', 'longitude', 'latitude', 'xmin', 'xmax', 'ymin', 'ymax']
f.write(','.join(header))
f.write('\n')
for th, line in enumerate(lines):
    if th < 29:
        continue
    else:
        words = line.split('; ')
        words[4] = words[4].replace(',', ' ')
        words = words[0:2] + [words[4], words[62], words[61], words[66], words[65], words[64], words[63]]
        f.write(','.join(words))
        f.write('\n')
f.close()
