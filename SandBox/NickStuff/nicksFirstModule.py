from framework.latentmodule import LatentModule
import random

class Main(LatentModule):
    def __init__(self):
        LatentModule.__init__(self)

        # set defaults for some configurable parameters:
        self.trials1 = 5            # number of trials in first part
        self.trials2 = 300            # number of trials in second part
        self.a_probability = 0.5    # probability that an "A" appears instead of a "U"

    def run(self):
        self.rectangle((1,1.5,-.75,-1),duration = 1000,color=(0,0,0,1),block = False)
        self.sleep(45)
        self.rectangle((1,1.5,-.75,-1),duration=1,color=(1,1,1,1),block = False)
        self.marker(700)  # emit an event marker to indicate the beginning of the experiment

        self.write('In the second part...I mean first and only part, you will be presented a picture of\na monkey eating a banana. When you see it, close your eyes.\n When you hear the bell, open them',5)
        self.write('The sound of a double bell will indicate the end of the experiment.',2)
        t = 0
        for k in range(self.trials2):
            self.crosshair(1)
            if  self.a_probability > random.random():
                self.rectangle((1,1.5,-.75,-1),duration=3,color=(1,1,1,1),block = False)
                self.marker(769)
                self.picture('monkey.jpg',2,scale=0.3,block = False)
                self.a_probability = self.a_probability - .1
            else:
                self.rectangle((1,1.5,-.75,-1),duration=3,color=(1,1,1,1),block = False)
                self.marker(770)
                self.picture('tool.jpg',2,scale=0.3,block = False)
                self.a_probability = self.a_probability + .1
            self.sleep(3)
            self.marker(768)
            self.sound('nice_bell.wav',volume=0.75)
            # wait for a an ISI randomly chosen between 1 and 3 seconds
            self.sleep(5)

        self.sound('nice_bell.wav',volume=0.75)
        self.sound('nice_bell.wav',volume=0.75)
        self.marker(11)
        self.write('You have successfully completed the experiment!')
