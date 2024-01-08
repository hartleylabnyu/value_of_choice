//------------------------------------//
// Define parameters.
//------------------------------------//

// Define image scaling CSS.
const style = "width:auto; height:auto; max-width:100%; max-height:80vh;";

// Define reward probabilities (per context)
const probs = [
  [0.90, 0.10],
  [0.70, 0.30],
  [0.50, 0.50],
]

// Define reward values.
const rewards = [10, 0];

// Define offers range.
const bonus_offers = [0, 1, 2, 3, 4, 5, 6];

// Define arcade colors.
const arcade_colors = jsPsych.randomization.shuffle([
  jsPsych.randomization.shuffle(["#D8271C", "#741CD8"]),    // red, purple
  jsPsych.randomization.shuffle(["#3386FF", "#D89F1C"]),    // blue, orange
  jsPsych.randomization.shuffle(["#1CD855", "#FA92F8"]),    // green, pink
]);

//------------------------------------//
// Define audio test.
//------------------------------------//

// Define beep test trial.
var beep_test = {
  type: 'audio-keyboard-response',
  stimulus: 'static/audio/beep_loop.wav',
  choices: jsPsych.ALL_KEYS,
  prompt: 'Make sure your sound is turned on. </p> Then, press the space bar to proceed to the audio test.',
};

// Define audio test trial 1.
var audio_test_1 = {
  type: 'audio-test',
  stimulus: 'static/audio/turtle.wav',
  choices: ['repeat', 'fish', 'tiger', 'turtle', 'shark'],
  correct_answer: 3,
  prompt: 'Click on the word that you just heard.',
  incorrect_prompt: 'Incorrect, please adjust your volume and try again.',
  margin_vertical: '40px',
  margin_horizontal: '10px',
  button_html: [
    '<img src="static/img/replay.png" height="200px" width="200px"/>',
    '<img src="static/img/fish.png" height="200px" width="200px"/>',
    '<img src="static/img/tiger.png" height="200px" width="200px"/>',
    '<img src="static/img/turtle.png" height="200px" width="200px"/>',
    '<img src="static/img/shark.png" height="200px" width="200px"/>'
  ],
  post_trial_gap: 1000
};

var audio_test_2 = {
  type: 'audio-test',
  stimulus: 'static/audio/shark.wav',
  choices: ['repeat', 'turtle', 'shark', 'fish', 'tiger'],
  correct_answer: 2,
  prompt: 'Again, click on the word that you just heard.',
  incorrect_prompt: 'Incorrect, please adjust your volume and try again.',
  margin_vertical: '40px',
  margin_horizontal: '10px',
  button_html: [
    '<img src="static/img/replay.png" height="200px" width="200px"/>',
    '<img src="static/img/turtle.png" height="200px" width="200px"/>',
    '<img src="static/img/shark.png" height="200px" width="200px"/>',
    '<img src="static/img/fish.png" height="200px" width="200px"/>',
    '<img src="static/img/tiger.png" height="200px" width="200px"/>'
  ],
  post_trial_gap: 1000
};


//------------------------------------//
// Define free choice task.
//------------------------------------//

// Define reward generator.
function returnReward(p) {
  return Math.random() < p ? rewards[0] : rewards[1];
}

// Define block structure.
const factors = {
  context: [0, 1, 2],
  bonus_offer: bonus_offers
}

// Iteratively construct task.
var fcp_trials = [];
var trial_no = 0;

for (let i = 0; i < 15; i++) {

  // Define block structure.
  while (true) {

    // Shuffle trial order
    var block = jsPsych.randomization.factorial(factors, 1);

    // Check maximum sequence length.
    const seqmax = longestSequence(block.map(a => a.context));

    // Accept if longest sequence is length = 4.
    if ( seqmax < 5 ) { break };

  }

  // Iterate over trials.
  block.forEach((info) => {

    // Define trial information.
    if (Math.random() < 0.5) {
      info.correct = 1;
      info.arcade_ids = [ 2 * info.context, 2 * info.context + 1 ];
      info.arcade_outcomes = probs[info.context].map(returnReward);
      info.arcade_colors = arcade_colors[info.context];
      info.arcade_probs = probs[info.context];
    } else {
      info.correct = 0;
      info.arcade_ids = [ 2 * info.context + 1, 2 * info.context ];
      info.arcade_outcomes = probs[info.context].slice().reverse().map(returnReward);
      info.arcade_colors = arcade_colors[info.context].slice().reverse();
      info.arcade_probs = probs[info.context].slice().reverse();
    }

    // Construct trial.
    const trial = {
      type: 'fcp-trial',
      bonus_offer: info.bonus_offer,
      correct: info.correct,
      arcade_outcomes: info.arcade_outcomes,
      arcade_colors: info.arcade_colors,
      data: {
        context: info.context,
        reward_prob_L: info.arcade_probs[0],
        reward_prob_R: info.arcade_probs[1],
        arcade_id_L: info.arcade_ids[0],
        arcade_id_R: info.arcade_ids[1],
        phase: 'experiment',
        trial: trial_no + 1,
        block: Math.floor(trial_no / 45) + 1
      },
    }

    // Define looping node.
    const trial_node = {
      timeline: [trial],
      loop_function: function(data) {
      }
    }

    // Append trial.
    fcp_trials.push(trial_node);

    // Increment trial counter
    trial_no++;

  });

}

//------------------------------------//
// Define transition screens.
//------------------------------------//

 // Define full screen enter.
 var fullscreen = {
  type: 'fullscreen',
  fullscreen_mode: true
};


// Define ready screen.
var ready = {
  type: 'audio-instructions',
  prompt: [
    `<img src="static/img/instructions/ready.png" style="${style}"></img>`,
  ],
  stimulus: ['static/audio/ready.wav'],
  choices: ['Start real game!'],
}

// Define break.
var pause = {
  type: 'audio-instructions',
  prompt: [
    `<img src="static/img/instructions/pause.png" style="${style}"></img>`,
  ],
  stimulus: ['static/audio/pause.wav'],
  choices: ['Next'],
}

// Define finish screen.
var finished = {
  type: 'audio-instructions',
  prompt: [
    `<img src="static/img/instructions/finish.png" style="${style}"></img>`,
  ],
  stimulus: ['static/audio/finished.wav'],
  choices: ['Next'],
}

// End screen
var end_screen = {
  type: 'audio-instructions',
  prompt: [
    `<img src="static/img/instructions/end.png" style="${style}"></img>`,
  ],
  stimulus: ['static/audio/end.wav'],
  choices: ['Finish experiment'],
}

//------------------------------------//
// Define explicit knowledge task.
//------------------------------------//

// Iteratively construct task.
var explicit_knowledge = [];
var machines = 
jsPsych.randomization.shuffle(["static/img/machines/machine1.png",
"static/img/machines/machine2.png",
"static/img/machines/machine3.png",
"static/img/machines/machine4.png",
"static/img/machines/machine5.png",
"static/img/machines/machine6.png"]);

for (let i = 0; i < 6; i++) {

    // Construct trial.
    const explicit_trial = {
      type: 'image-slider-response',
      stimulus: machines[i],
      stimulus_height: 300,
      min: 1, 
      max: 9,
      start: 5,
      step: 1,
      labels: [1, 2, 3, 4, 5, 6, 7, 8, 9],
      prompt: "If you played this machine 10 times, how many times would you win? <br> <br>",
      button_label: "Submit response",
      data: {
        phase: 'explicit',
        stimulus: machines[i]
      },
    }

    // Append trial.
    explicit_knowledge.push(explicit_trial);

  };



//---------------------------------------//
// Define functions.
//---------------------------------------//

function longestSequence( arr ) {

  // Initialize variables.
  var counts = [0,0];
  var seqmax = 0;

  arr.forEach((i) => {

    // Increment counts.
    counts = counts.map(function(v){return ++v;});

    // Reset counter of context.
    counts[i] = 0;

    // Update sequence length max.
    if ( Math.max(...counts) > seqmax ) { seqmax = Math.max(...counts) };

  });

  return seqmax

}


