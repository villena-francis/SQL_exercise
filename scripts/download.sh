file=$1
dir=$2

#Download data file
wget -nc -P $2 $1

#Generate md5 data file
data_file="$2/$(basename $1)"

md5sum "$data_file" > "$data_file.md5"