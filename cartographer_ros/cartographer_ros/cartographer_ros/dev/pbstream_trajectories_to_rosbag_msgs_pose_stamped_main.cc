/*
 * Copyright 2017 Michael Grupp, grupp@magazino.eu
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <string>
#include <vector>

#include "cartographer/io/proto_stream.h"
#include "cartographer/mapping/proto/pose_graph.pb.h"
#include "cartographer/io/proto_stream_deserializer.h"
#include "cartographer/transform/transform.h"
#include "cartographer_ros/msg_conversion.h"
#include "cartographer_ros/time_conversion.h"
#include "geometry_msgs/PoseStamped.h"
#include "gflags/gflags.h"
#include "glog/logging.h"
#include "ros/ros.h"
#include "rosbag/bag.h"

DEFINE_string(pbstream_filename, "",
              "Filename of a pbstream to draw the pose graph from.");
DEFINE_string(bag_filename, "", "Filename of the output bag file.");
DEFINE_string(frame_id, "map",
              "Desired frame_id field for the headers of the messages.");
DEFINE_string(topic_prefix, "trajectory_",
              "Trajectory topics will be named <prefix><Trajectory ID>");
DEFINE_bool(append, false, "Whether to append to an existing bag file.");

namespace cartographer_ros {
namespace {

namespace carto = ::cartographer;
using cartographer::transform::Rigid3d;

// conversion in style of cartographer_ros' msg_conversion.cc
geometry_msgs::PoseStamped ToGeometryMsgPoseStamped(int64_t timestamp_uts,
                                                    const std::string& frame_id,
                                                    const Rigid3d& rigid3d) {
  geometry_msgs::PoseStamped pose_stamped;
  pose_stamped.header.stamp =
      cartographer_ros::ToRos(
      ::cartographer::common::FromUniversal(timestamp_uts));
  pose_stamped.header.frame_id = frame_id;
  pose_stamped.pose = cartographer_ros::ToGeometryMsgPose(rigid3d);
  return pose_stamped;
}


void Run(const std::string& pbstream_filename, const std::string& bag_filename,
         const std::string& frame_id, const std::string& topic_prefix,
         const bool append) {
  carto::io::ProtoStreamReader reader(pbstream_filename);
  carto::io::ProtoStreamDeserializer deserializer(&reader);

  carto::mapping::proto::PoseGraph pose_graph_proto = deserializer.pose_graph();

  std::vector<cartographer::mapping::proto::Trajectory> all_trajectories(
      pose_graph_proto.trajectory().begin(),
      pose_graph_proto.trajectory().end());

  LOG(INFO) << "Exporting trajectories to " << bag_filename << "...";
  rosbag::Bag trajectory_bag;
  LOG(INFO) << "Numero de trajetorias" << all_trajectories.size();
  auto bagmode = append ? rosbag::bagmode::Append : rosbag::bagmode::Write;
  trajectory_bag.open(bag_filename, bagmode);
  for (size_t trajectory_id = 0; trajectory_id < pose_graph_proto.trajectory().size();
       ++trajectory_id) {
    const std::string topic = topic_prefix + std::to_string(trajectory_id);
    const carto::mapping::proto::Trajectory& trajectory_proto =
        pose_graph_proto.trajectory(trajectory_id);
    LOG(INFO) << "Writing " << topic << "...";
    for (int i = 0; i < trajectory_proto.node_size(); ++i) {
      const auto& node = trajectory_proto.node(i);
      auto msg = ToGeometryMsgPoseStamped(
          node.timestamp(), frame_id, carto::transform::ToRigid3(node.pose()));
      trajectory_bag.write(topic, msg.header.stamp, msg);
    }
  }
  trajectory_bag.close();
}

}  // namespace
}  // namespace cartographer_tools

int main(int argc, char** argv) {
  FLAGS_alsologtostderr = true;
  google::InitGoogleLogging(argv[0]);
  google::ParseCommandLineFlags(&argc, &argv, true);

  CHECK(!FLAGS_pbstream_filename.empty()) << "-pbstream_filename is missing.";
  CHECK(!FLAGS_bag_filename.empty()) << "-bag_filename is missing.";

  cartographer_ros::Run(FLAGS_pbstream_filename, FLAGS_bag_filename,
                          FLAGS_frame_id, FLAGS_topic_prefix, FLAGS_append);
}