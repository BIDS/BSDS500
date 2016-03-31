cd gpb_src
make clean
make
make matlab
cp -f matlab/segmentation/load_smatrix.mex* ../../lib/
cp -f matlab/segmentation/mex_contour_sides.mex* ../../lib/
cp -f matlab/segmentation/mex_nonmax_oriented.mex* ../../lib/
cp -f matlab/segmentation/mex_pb_parts_final_selected.mex* ../../lib/
cp -f matlab/segmentation/mex_pb_parts_lg.mex* ../../lib/
cp -f matlab/segmentation/mex_pb_parts_sm.mex* ../../lib/
cp -f matlab/segmentation/mex_line_inds.mex* ../../lib/
cd ..

cd buildW
make clean
make
cp -f buildW.mex* ../../lib/
cd ..

cd savgol 
matlab -nodisplay -nojvm -r "mex savgol_border.cpp; exit"
cp -f savgol_border.mex* ../../lib/
cd ..

cd ucm
matlab -nodisplay -nojvm -r "mex ucm_mean_pb.cpp; exit"
cp -f ucm_mean_pb.mex* ../../lib/
cd ..

cd uvt
matlab -nodisplay -nojvm -r "mex uvt.cpp; exit"
cp -f uvt.mex* ../../lib/
cd ..
