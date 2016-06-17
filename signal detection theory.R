
	# Signal Detection Theory and Reward demonstration for Sorkin and Woods (1985) Alerted Monitor.
	# Andrew Howes
	# June 2016
	
	# -------------------------------------
	
	# remove variable bindings.
	
rm(list=ls())

	# the number of samples (observations of smoke present or absent)
	
n <- 10000

	# dPrime (d') is the measure of how discriminable Noise is from Signal+Noise.
	
dPrime = 2

	# The value of Z when there is no signal present.
	
noSignalVal <- 0
signalVal <- noSignalVal + dPrime

sampler <- function(n) 
{
	sample(c(noSignalVal,signalVal),n, replace=T)
}

	# sample from the standard normal distribution.
	# note that dPrime is dependent on the standard deviation.
	# code should be updated to make sd and dPrime dependent.
	# can be used to sample either noise or signal plus noise.
		
noiseSampler <- function(samples) 
{
	l <- length(samples)
	return( samples+rnorm(l) )
}

	# estimate the probability of saying Y given a criterion threshold C and a vector of samples Z.
	
calcProbY <- function(C, samples) 
{
	sum(samples>C)/length(samples)
}

	# get Signal and Signal plus Noise samples for the automated monitor.
	
automated <- list()
automated$SN <- noiseSampler(rep(signalVal,n))
automated$N <-  noiseSampler(rep(noSignalVal,n))

	# open a plot file

pdf(file="sdt.pdf")

	# plot the densities of the automated monitor samples.
	
plot(density(automated$SN))
lines(density(automated$N), col=2)

	# define a vector of levels of the criterion C. These will be used to generate ROC curves.
	
Clevel <- seq(-2.5, 4.5, by=0.2)

	# Calculate the probabilities of Y for the automated monitor given SN and N.
	
Ya <- list()
for( i in 1:length(Clevel)) 
{
	Ya$SN[i] <- calcProbY(Clevel[i],automated$SN)
	Ya$N[i] <- calcProbY(Clevel[i],automated$N)
}

	# Plot the ROC curve
	
xx <- c(0,1)
yy <- c(0,1)
plot(Ya$N, Ya$SN, type="b", xlim=xx, ylim=yy)

	# --------------------------------

	# The ROC curve determines the probability of hits and false alarms for all values of C.
	# But a computationally rational agent will set a value of C so as to maximize utility/reward.
	
	# calculate a reward function and pot

reward <- 2 * Ya$SN - Ya$N

plot(Clevel, reward)


	# --------------------------------

	# up until now we have only calculated the behaviour of an automated monitor.
	# but the Alerted Monitor (Sorkin and Woods) alerts a human...
	
	# the human also monitors for signal in the noisy environment...
	
human <- list()
human$SN <- noiseSampler(rep(signalVal,n))
human$N <-  noiseSampler(rep(noSignalVal,n))

	# the alerted monitor (automation plus human) responds only when alerted and when it independently detects signal.
	
alertedMonitor <- function(Ca=0) 
{
	automatedSN <- automated$SN > Ca
	automatedN <- automated$N > Ca
	humanSN <- c(subset(human$SN, automatedSN), rep(-99, length(subset(human$SN, !automatedSN))))
	humanN <- c(subset(human$N, automatedN), rep(-99, length(subset(human$SN, !automatedSN))))

	Yh <- list()
	for( i in 1:length(Clevel) )
	{
		Ch <- Clevel[i]
		Yh$SN[i] <- calcProbY(Ch,humanSN)
		Yh$N[i] <- calcProbY(Ch,humanN)
	}
	lines(Yh$N, Yh$SN)
	reward <- Yh$SN - 3 * Yh$N
	return(reward)
}

	# plot the alerted monitor ROC curves
	
plot(0, type="n", col=4, xlim=xx, ylim=yy, xlab="P(Y|N)", ylab="P(Y|SN)")
r <- matrix(nrow=5, ncol=length(Clevel))
r[1,] <- alertedMonitor(Ca=-3.5)
r[2,] <- alertedMonitor(Ca=0)
r[3,] <- alertedMonitor(Ca=0.5)
r[4,] <- alertedMonitor(Ca=1)
r[5,] <- alertedMonitor(Ca=1.5)

	# plot the alerted monitor reward functions
	
plot(0, type="n", col=4, xlim=c(min(Clevel),max(Clevel)), ylim=c(0,max(r)), xlab="Criterion", ylab="reward")
for( i in 1:5 )
{
	lines(Clevel, r[i,], col=i)
}
graphics.off()

	# exercise: how is the design of Ca for the alerted monitor  dependent on the human reward function?
	
	# exercise: under what other conditions will the design of the automated monitor Ca change?
	
	# exercise: translate to Python.
	
	# exercise: implement function for calculating dPrime given noise distribution parameters and signal.