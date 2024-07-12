
SPLIT=controllability_02_unprotected_left # val14_split
CHALLENGE=closed_loop_reactive_agents # open_loop_boxes, closed_loop_nonreactive_agents, closed_loop_reactive_agents
EXPERIMENT_NAME=controllability_02_ours
RESULT_PATH=/home/yaory/nuplan/exp/exp/ctrl_res/results_$EXPERIMENT_NAME.json

for SEED in {1..10}
do
    python $NUPLAN_DEVKIT_ROOT/nuplan/planning/script/run_simulation.py \
    +simulation=$CHALLENGE \
    model=kinematic_diffusion_model \
    planner=pdm_diffusion_language_planner \
    planner.pdm_diffusion_language_planner.checkpoint_path="/home/yaory/nuplan/exp/exp/kinematic/kinematic/2024.06.25.20.53.42/checkpoints/epoch\=490.ckpt" \
    planner.pdm_diffusion_language_planner.dump_gifs_path="/home/yaory/nuplan/exp/exp/kinematic/viz/2024.06.25.20.53.42_controllability_02" \
    scenario_filter=$SPLIT \
    scenario_builder=nuplan \
    number_of_gpus_allocated_per_simulation=1.0 \
    hydra.searchpath="[pkg://tuplan_garage.planning.script.config.common, pkg://tuplan_garage.planning.script.config.simulation, pkg://nuplan.planning.script.config.common, pkg://nuplan.planning.script.experiments]" \
    worker=sequential \
    observation=noisy_idm_agents_observation \
    metric_aggregator=closed_loop_reactive_agents_weighted_average_no_prog \
    ego_controller=one_stage_controller \
    seed=$SEED \
    experiment_name=$EXPERIMENT_NAME \
    planner.pdm_diffusion_language_planner.experiment_log_path=$RESULT_PATH \
    planner.pdm_diffusion_language_planner.nuplan_output_dir=\${output_dir} \
    planner.pdm_diffusion_language_planner.language_config.instruction="If car 18 is within 20 meters yield to it. Otherwise it will slow for you."
done

python tuplan_garage/process_results.py --result_path $RESULT_PATH
