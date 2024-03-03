for dir in data database questions
do
    find "$dir" -mindepth 1 -not -name ".gitkeep" -not -name "url" -delete
    echo "$dir was cleaned"
done