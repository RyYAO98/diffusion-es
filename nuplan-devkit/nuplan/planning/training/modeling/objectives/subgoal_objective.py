from typing import Dict, List, cast

import torch

from nuplan.planning.training.modeling.objectives.abstract_objective import AbstractObjective
from nuplan.planning.training.modeling.objectives.scenario_weight_utils import extract_scenario_type_weight
from nuplan.planning.training.modeling.types import FeaturesType, ScenarioListType, TargetsType
from nuplan.planning.training.preprocessing.features.trajectory import Trajectory


class SubgoalObjective(AbstractObjective):

    def __init__(self, scenario_type_loss_weighting: Dict[str, float], weight: float = 1.0):
        """
        Initializes the class

        :param name: name of the objective
        :param weight: weight contribution to the overall loss
        """
        self._name = 'subgoal_objective'
        self._weight = weight

        self._fn_xy = torch.nn.modules.loss.L1Loss(reduction='none')
        self._fn_heading = torch.nn.modules.loss.L1Loss(reduction='none')

        self._subgoal_idx = 4

    def name(self) -> str:
        """
        Name of the objective
        """
        return self._name

    def get_list_of_required_target_types(self) -> List[str]:
        """Implemented. See interface."""
        return []

    def compute(self, predictions: FeaturesType, targets: TargetsType, scenarios: ScenarioListType) -> torch.Tensor:
        """
        Computes the objective's loss given the ground truth targets and the model's predictions
        and weights it based on a fixed weight factor.

        :param predictions: model's predictions
        :param targets: ground truth targets from the dataset
        :return: loss scalar tensor
        """
        if 'loss_weight' in predictions:
            weight = predictions["loss_weight"].squeeze(1)
        else:
            weight = 1.0

        pred_goal = predictions['subgoal']
        gt_goal = targets['trajectory'].data[:,self._subgoal_idx]

        xy_loss = self._fn_xy(pred_goal[:,:2], gt_goal[:,:2])
        ori_loss = self._fn_heading(pred_goal[:,2], gt_goal[:,2])

        loss = (xy_loss.sum(dim=1) + ori_loss) * weight
        loss = loss.mean()
        return loss
