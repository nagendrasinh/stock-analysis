#!/bin/sh

#SBATCH -A skamburu
#SBATCH -N 28
#SBATCH --tasks-per-node=24
#SBATCH --time=12:00:00

YEARLY_DISTANCES_DIR=$BASE_DIR/$YEARLY_DISTANCES_DIR_NAME
YEARLY_HEATMAP_DIR=$BASE_DIR/$YEARLY_HEATMAP_DIR_NAME

mkdir -p $YEARLY_HEATMAP_DIR

$BUILD/bin/mpirun --report-bindings --mca btl ^tcp java -cp  ../mpi/target/stocks-1.0-ompi1.8.1-jar-with-dependencies.jar SHeatMapGenerator -c heatmap.properties -o $YEARLY_HEATMAP_DIR -m -p $BASE_DIR/$YEARLY_MDS_DIR_NAME -d YEARLY_DISTANCES_DIR

GLOBAL_DISTANCES_DIR_NAME=$BASE_DIR/$GLOBAL_PREPROC_DIR_NAME/distances
GLOBAL_HEATMAP_DIR=$BASE_DIR/$GLOBAL_POSTPROC_DIR_NAME/heatmap

mkdir -p $GLOBAL_HEATMAP_DIR
GLOBAL_HEAT_POINTS=$BASE_DIR/$GLOBAL_MDS_DIR_NAME/*
for f in $GLOBAL_HEAT_POINTS
do
  echo "heatmap dir" $GLOBAL_HEATMAP_DIR
  common_filename="${f##*/}"
  common_filename_ext="${common_filename%.*}"
  common_file=$BASE_DIR/$GLOBAL_MDS_DIR_NAME/$common_filename
  echo 'common file' $common_file
  no_of_common_lines=`sed -n '$=' $common_file`
  echo $no_of_common_lines

  ext='.csv'
  distance_file=$GLOBAL_DISTANCES_DIR_NAME/$common_filename_ext$ext

  echo "distance file" $distance_file
  echo "point file" $common_file
  echo "-Drows=$no_of_common_lines -Dcols=$no_of_common_lines -DAmat=$common_file -DBmat=$distance_file -DscaleB=1.0 -Dtitle=$common_filename -Doutdir=$YEARLY_HEATMAP_DIR -cp ../mpi/target/stocks-1.0-ompi1.8.1-jar-with-dependencies.jar SHeatMapGenerator -c heatmap.properties"

  java -Drows=$no_of_common_lines -Dcols=$no_of_common_lines -DAmat=$common_file -DBmat=$distance_file -Dtitle=$common_filename_ext -Doutdir=$GLOBAL_HEATMAP_DIR -cp ../mpi/target/stocks-1.0-ompi1.8.1-jar-with-dependencies.jar SHeatMapGenerator -c heatmap.properties

  cat $GLOBAL_HEATMAP_DIR/plot.bat >> $GLOBAL_HEATMAP_DIR/plot_master.sh
done