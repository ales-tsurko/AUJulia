const sr = 44100.0
frequency = 440.0

##########
# Phasor
##########

type PhaseCounter
  sr::Float64
  ф::Float64
  incr::Float64
end

counter = PhaseCounter(sr, 0., frequency/sr)

function phasor(c::PhaseCounter)
  c.ф = mod(c.ф + c.incr, 1)
  return c.ф
end

###################
# Sine oscillator
###################

function sin_osc(freq::Float64, amp::Float64)
  counter.incr = freq / sr
  return sin(pi * 2 * phasor(counter)) * amp
end

