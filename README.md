
# Detection Proposals

Evaluation of detection proposal algorithms. The code belongs to the BMVC paper **How good are detection proposals, really?** and an upcoming journal paper. Have a look at the [Project Page](http://www.mpi-inf.mpg.de/departments/computer-vision-and-multimodal-computing/research/object-recognition-and-scene-understanding/how-good-are-detection-proposals-really/) for more information.


Please contact me if you're having trouble with the code!



## Plot evaluation curves

1. Get the data that you want to use from the [Project Page](http://www.mpi-inf.mpg.de/departments/computer-vision-and-multimodal-computing/research/object-recognition-and-scene-understanding/how-good-are-detection-proposals-really/).
2. Edit `get_config.m` to point to the right locations for images, candidates and so on.
3. Make sure you either start matlab in the root directory of the code or run `startup.m` manually once.
4. Run `plot_recall_voc07.m`, curves will be in the figures subdirectory.



## Benchmark your own method

1. Follow **Plot evaluation curves**.
2. Write a wrapper function that takes an image and the number of proposal boxes and returns the proposals and scores. Proposals are a nx4 matrix, where n is the number of proposals and every row has the format `[x1 y1 x2 y2]` (x and y are 1-based image coordinates). See `method_wrappers/` for examples.
2. Add your method to `shared/get_method_configs.m`
3. Run `compute_recall_candidates_voc07.m` passing only the config of your method as an argument. If your method is slow, you probably want to parallelize it in a cluster.
4. Run `plot_recall_voc07.m`, curves will be in the figures subdirectory.

You don't have to use `compute_recall_candidates_voc07.m`, but you can have a look to get an idea about how to save the candidates in the right format so, `plot_recall_voc07.m` will be able to read it.


## Format of the precomputed proposals

For the recall experiments, there is one mat file per image, each storing the
proposals for that image.  There are two cases of how proposals are stored.  In
the easiest case the proposals can be filtered after we have generated enough
of them, for example because they are sorted or scored.  If this is not the
case we need to rerun the proposal method for different number of proposals
that we would like to evaluate.

In both cases the each mat file contains the variables `boxes`, `scores`, and
`num_candidates`.


#### Proposals can be filtered

`boxes` is a n-by-4 matrix in which each row is of the format `[x1 y1 x2 y2]`
(x and y are 1-based image coordinates).

`scores` is a column vector of length n, containing scores for each of the
proposals in `boxes`. How these scores are to be used to find the top k
proposals is specified per method in `shared/get_method_configs.m`. `scores`
can also be empty, then the only valid choice for ordering is `none` (proposals
are already sorted) or `random` (proposals should be shuffled before using the
first k).

`num_candidates` should be empty or n.


#### Proposals cannot be filtered

In this case the proposal method will be called several times with different
`num_candidates` parameter, so we can make a plot for varying number of
proposals. Let's say we run the proposal method d=4 times with the
`num_candidates` = 10, 100, 1000, 10000. These parameters are saved as a column
vector in the `num_candidates` variable in the mat file.

`boxes` and `scores` are now cells with d elements. Each element of the cells
are as described above (for proposals that can be filtered) and contain
proposals and scores for each of the d reruns of the proposal method.

#### Implementation

If you want more details you can have a look at the files
`compute_recall_candidates_voc07.m` around lines 39-65 and at the functions
that are called there (`read_candidates_mat`, `save_candidates_mat`).
