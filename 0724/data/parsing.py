import pandas as pd


def main():
    # Read excel data
    filepath = './treedb.xlsx'
    occur_df = pd.read_excel(filepath, sheetname=0)
    tree_id_df = pd.read_excel(filepath, sheetname=2)

    # Make a dictionary for tree name mapping (kor: eng)
    name_dict = {}
    for kor, eng in zip(tree_id_df['Korean_name'], tree_id_df['scientific_name']):
        name_dict[kor] = eng

    # Make name list for occurrence data in English
    names = list(occur_df['kind'])
    for th, kor in enumerate(names):
        eng = kor2eng(name_dict, kor)
        names[th] = eng

    # Make a data frame for the English names
    eng_occur_dict = {}
    eng_occur_dict['kind'] = names
    eng_occur_dict['lon'] = occur_df['lon']
    eng_occur_dict['lat'] = occur_df['lat']
    eng_occur_df = pd.DataFrame(eng_occur_dict)

    # Save the result
    writer = pd.ExcelWriter(filepath)
    occur_df.to_excel(writer, 'occurrence', index=False)
    eng_occur_df.to_excel(writer, 'occurrence_eng', index=False)
    tree_id_df.to_excel(writer, 'tree_code', index=False)
    writer.save()


# Define a function for finding out English name of a Korean name
def kor2eng(name_dict, kor_name):
    if kor_name in name_dict:
        return name_dict[kor_name]
    else:
        for kor in name_dict:
            if is_head_elapsed(kor, kor_name):
                return name_dict[kor]
        return kor_name


# Define a function for checking if two strings has the same front part
def is_head_elapsed(s1, s2):
    # Get heads
    h1 = s1.split()[0]
    h2 = s2.split()[0]

    # Check if heads are elapsed
    if len(h1) < len(h2):
        return h1 == h2[:len(h1)]
    else:
        return h1[:len(h2)] == h2


if __name__ == '__main__':
    main()

