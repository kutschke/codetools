#!/usr/bin/python
import sys

def remove_trailing(lines):
    return [l.rstrip() for l in lines]

def replace_hardtabs(lines):
    return [l.lstrip("\t") for l in lines]

def main():
    if len(sys.argv) < 2:
        print ('%s: no input file' % sys.argv[0])
        return
    input_file = sys.argv[1]
    file_lines = []
    
    with open(input_file, 'r') as f:
        file_lines = [l.rstrip('\n') for l in f.readlines()]
    
    t_fixed_lines = remove_trailing(file_lines)
    changed_lines_trailing = sum([1 for before, after in zip(file_lines, t_fixed_lines) if before != after])
    
    fixed_lines = replace_hardtabs(t_fixed_lines)
    changed_lines_tabs = sum([1 for before, after in zip(t_fixed_lines, fixed_lines) if before != after])
    

    with open(input_file, 'w') as f:
        f.write('\n'.join(fixed_lines))
    
    changed_lines = sum([1 for before, after in zip(file_lines, fixed_lines) if before != after])
    print ('removed trailing whitespace on %d lines' % changed_lines_trailing)
    print ('removed leading hard tabs on %d lines' % changed_lines_tabs)
    print ('changed %d lines' % changed_lines)

if __name__ == '__main__':
    main()
