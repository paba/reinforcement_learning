#!/usr/bin/env python
__author__ = 'Thomas Rueckstiess, ruecksti@in.tum.de'

""" This example demonstrates how to use the discrete Temporal Difference
Reinforcement Learning algorithms (SARSA, Q, Q(lambda)) in a classical
fully observable MDP maze task. The goal point is the top right free
field. """

from scipy import *
#import sys, time
#import numpy as np


from maze_menu_sequential import Maze
from mdp_menu_sequential import MDPMazeTask
from pybrain.rl.learners.valuebased import ActionValueTable
from pybrain.rl.agents import LearningAgent
from pybrain.rl.learners import Q
from pybrain.rl.experiments import Experiment

import pylab
pylab.gray()
pylab.ion()


# create the maze with walls (1)
matrix_size = 7
envmatrix = array([[0,0,0,0,0,0,1]])

env = Maze(envmatrix,(0,2))

# create task
task = MDPMazeTask(env)



# create value table and initialize with ones
#table = ActionValueTable(7, 2)
table = ActionValueTable(matrix_size, 2)
#table = ActionValueTable(matrix_size, matrix_size)
table.initialize(1.)


# create agent with controller and learner - use SARSA(), Q() or QLambda() here
learner = Q()

# standard exploration is e-greedy, but a different type can be chosen as well
# learner.explorer = BoltzmannExplorer()

# create agent
agent = LearningAgent(table, learner)

# create experiment
experiment = Experiment(task, agent)

# prepare plotting
pylab.gray()
pylab.ion()

#for i in range(100):
while True:
    # interact with the environment (here in batch mode)
    experiment.doInteractions(matrix_size)
    agent.learn()
    agent.reset()

    # and draw the table
    print table.params.reshape(matrix_size,2)
    #print table.params.reshape(matrix_size,matrix_size)
    pylab.pcolor(table.params.reshape(matrix_size,2).max(1).reshape(matrix_size,1))
    #pylab.pcolor(table.params.reshape(matrix_size,matrix_size).max(1).reshape(matrix_size,1))
    pylab.draw()
    pylab.ion()
    pylab.show()
print "training complete"
