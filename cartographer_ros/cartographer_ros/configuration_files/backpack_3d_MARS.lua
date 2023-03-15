-- Copyright 2016 The Cartographer Authors
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

include "map_builder.lua"
include "trajectory_builder.lua"

options = {
  map_builder = MAP_BUILDER,
  trajectory_builder = TRAJECTORY_BUILDER,
  map_frame = "map",
  tracking_frame = "xsens_imu_link", --base_link
  published_frame = "odom",
  odom_frame = "odom",
  provide_odom_frame = false,
  publish_frame_projected_to_2d = false,
  use_pose_extrapolator = true,
  use_odometry = true,
  use_nav_sat = false,
  use_landmarks = false,
  num_laser_scans = 0,
  num_multi_echo_laser_scans = 0,
  num_subdivisions_per_laser_scan = 1,
  num_point_clouds = 2,
  lookup_transform_timeout_sec = 0.2,
  submap_publish_period_sec = 0.3,
  pose_publish_period_sec = 5e-3,
  trajectory_publish_period_sec = 30e-3,
  rangefinder_sampling_ratio = 1.,
  odometry_sampling_ratio = 1.,
  fixed_frame_pose_sampling_ratio = 1.,
  imu_sampling_ratio = 1.,
  landmarks_sampling_ratio = 1.,
}


--TRAJECTORY_BUILDER_3D.high_resolution_adaptive_voxel_filter.max_length = 5.
--TRAJECTORY_BUILDER_3D.high_resolution_adaptive_voxel_filter.min_num_points = 250.
--TRAJECTORY_BUILDER_3D.low_resolution_adaptive_voxel_filter.max_length = 8.
--TRAJECTORY_BUILDER_3D.low_resolution_adaptive_voxel_filter.min_num_points = 400.

TRAJECTORY_BUILDER_3D.submaps.range_data_inserter.hit_probability = 0.6
TRAJECTORY_BUILDER_3D.submaps.range_data_inserter.miss_probability = 0.49


--------------Ceres Scan Matcher--------------------------
--TRAJECTORY_BUILDER_2D.ceres_scan_matcher.occupied_space_weight = 1
TRAJECTORY_BUILDER_3D.ceres_scan_matcher.translation_weight = 5.
TRAJECTORY_BUILDER_3D.ceres_scan_matcher.rotation_weight = 20.

------------ Online Correlative Scan Matching-------------
TRAJECTORY_BUILDER_3D.use_online_correlative_scan_matching = true

---------------Trajectory Builder-----------------------
TRAJECTORY_BUILDER_3D.num_accumulated_range_data = 2
-- TRAJECTORY_BUILDER_3D.scans_per_accumulation = 1

TRAJECTORY_BUILDER_2D.use_imu_data = true 

TRAJECTORY_BUILDER_3D.min_range = 1.
TRAJECTORY_BUILDER_3D.max_range = 20.
TRAJECTORY_BUILDER_3D.submaps.num_range_data = 100

TRAJECTORY_BUILDER_3D.submaps.high_resolution = 0.1
TRAJECTORY_BUILDER_3D.submaps.high_resolution_max_range = 20

TRAJECTORY_BUILDER_3D.voxel_filter_size = 0.15
TRAJECTORY_BUILDER_3D.high_resolution_adaptive_voxel_filter.max_length = 2.
TRAJECTORY_BUILDER_3D.high_resolution_adaptive_voxel_filter.max_range = 15.

TRAJECTORY_BUILDER_3D.ceres_scan_matcher.occupied_space_weight_0 = 1.
TRAJECTORY_BUILDER_3D.ceres_scan_matcher.occupied_space_weight_1 = 6.
--TRAJECTORY_BUILDER_3D.rotational_histogram_size = 120

--TRAJECTORY_BUILDER_3D.pose_extrapolator.constant_velocity.imu_gravity_time_constant = 10.
--TRAJECTORY_BUILDER_3D.pose_extrapolator.constant_velocity.pose_queue_duration = 0.001


TRAJECTORY_BUILDER_3D.pose_extrapolator.imu_based.pose_queue_duration = 5.

TRAJECTORY_BUILDER_3D.pose_extrapolator.imu_based.gravity_constant = 9.806

TRAJECTORY_BUILDER_3D.pose_extrapolator.imu_based.pose_translation_weight = 1.

TRAJECTORY_BUILDER_3D.pose_extrapolator.imu_based.pose_rotation_weight = 1.

TRAJECTORY_BUILDER_3D.pose_extrapolator.imu_based.imu_acceleration_weight = 1.

TRAJECTORY_BUILDER_3D.pose_extrapolator.imu_based.imu_rotation_weight = 1.

TRAJECTORY_BUILDER_3D.pose_extrapolator.imu_based.odometry_translation_weight = 1.

TRAJECTORY_BUILDER_3D.pose_extrapolator.imu_based.odometry_rotation_weight = 1.




--------------RealTimeCorrelativeScanMatcher-------------
--TRAJECTORY_BUILDER_3D.use_online_correlative_scan_matching = true
--TRAJECTORY_BUILDER_3D.real_time_correlative_scan_matcher.linear_search_window = 0.15
--TRAJECTORY_BUILDER_3D.real_time_correlative_scan_matcher.angular_search_window = math.rad(20.)
--TRAJECTORY_BUILDER_3D.real_time_correlative_scan_matcher.translation_delta_cost_weight = 10
--TRAJECTORY_BUILDER_3D.real_time_correlative_scan_matcher.rotation_delta_cost_weight = 1e-1

--------------MAP Builder---------------------------------

MAP_BUILDER.use_trajectory_builder_3d = true
MAP_BUILDER.num_background_threads = 7


--------------PoseGraph Optimization----------------------
--POSE_GRAPH.optimization_problem.use_online_imu_extrinsics_in_3d = true
POSE_GRAPH.optimization_problem.huber_scale = 5e2
-- POSE_GRAPH.optimize_every_n_nodes = 320
POSE_GRAPH.optimize_every_n_nodes = 100
POSE_GRAPH.constraint_builder.sampling_ratio = 0.03
POSE_GRAPH.optimization_problem.ceres_solver_options.max_num_iterations = 10
POSE_GRAPH.constraint_builder.min_score = 0.62
POSE_GRAPH.constraint_builder.global_localization_min_score = 0.66

return options
