#!/usr/bin/env fish

for jekyll_file in (ls -1  ../provision/roles/blog/files/_posts/*.md)
    set slug blog/(basename $jekyll_file | cut -b 12- | cut -f 1 -d '.')
    set date (basename $jekyll_file | cut -b 1-10)
    set pelican_file content/$slug.md
    set title (grep 'title:' $jekyll_file | cut -b 8-)
    set header "Title: $title\nDate: $date 22:00\nSlug: $slug\n"

    echo $jekyll_file
    echo -e $header >$pelican_file
    cat $jekyll_file | tail -n +2 | awk 'BEGIN{IGNORECASE = 1} f; /---/ {f=1}' >>$pelican_file
end
