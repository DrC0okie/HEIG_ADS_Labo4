#!/bin/bash

raw_dir="lab04_raw_files"
output_file="page.html"
template_begin="template_begin.html"
template_end="template_end.html"

# Check if ImageMagick is installed

if ! command -v convert &> /dev/null; then
    echo "ImageMagick is not installed. Please install it to continue."
    exit 1
fi

# Generate the middle section
middle_content="<article class=\"container article\">\n"
middle_content+="<div class=\"row\">\n"
middle_content+="<div class=\"col-md-10 col-md-pull-3 col-md-offset-4 article__content\">\n"
middle_content+="<div><div><h2>Découvrez-nous en images</h2></div></div>\n"
middle_content+="<div class=\"row\">\n"

# Iterate over the JPEG files in the raw_files directory to generate thumbnail links and full-size image links.

for img in "$raw_dir"/*.jpg; do
    filename=$(basename "$img")
    thumbnail="${filename%.*}_thumb.jpg"
	
	# Use convert from ImageMagick to create thumbnails if they don't already exist
	
    if [ ! -f "$raw_dir/$thumbnail" ]; then
        convert "$img" -resize 200x200 "$raw_dir/$thumbnail"
    fi
    middle_content+="<div class=\"col-md-6 col-xs-12\">\n"
    middle_content+="<a href=\"files/$filename\"><img class=\"vignette\" src=\"files/$thumbnail\" /></a>\n"
    middle_content+="</div>\n"
done

middle_content+="</div>\n"
middle_content+="</div>\n"
middle_content+="</div>\n"

# Add the Brochures Section

middle_content+="<div class=\"row\" style=\"margin-top: 40px;\">\n"
middle_content+="<div class=\"col-md-10 col-md-pull-3 col-md-offset-4 article__content\">\n"
middle_content+="<div><div><h2>Téléchargez nos brochures</h2></div></div>\n"
middle_content+="<div class=\"row\">\n"

for pdf in "$raw_dir"/*.pdf; do
    pdf_filename=$(basename "$pdf")
    preview="${pdf_filename%.*}.jpg"
    if [ ! -f "$raw_dir/$preview" ]; then
        # Assuming previews are manually created or use a tool to generate
        echo "No preview available for $pdf"
    fi
    middle_content+="<div class=\"col-md-6 col-xs-12\">\n"
    middle_content+="<a href=\"files/$pdf_filename\"><img class=\"vignette\" src=\"files/$preview\" /></a>\n"
    middle_content+="</div>\n"
done

middle_content+="</div>\n"
middle_content+="</div>\n"
middle_content+="</div>\n"
middle_content+="</article>\n"

# Concatenate the beginning template, the generated middle content, and the end template, then write to the page.html file
{ cat "$template_begin"; echo "$middle_content"; cat "$template_end"; } > "$output_file"
