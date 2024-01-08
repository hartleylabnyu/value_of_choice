/**
 * jspsych-fcp-practice
 * Sam Zorowitz
 *
 * free choice paradigm trial
 *
 **/

jsPsych.plugins["fcp-practice"] = (function() {

  var plugin = {};

  plugin.info = {
    name: 'fcp-practice',
    description: '',
    parameters: {
      correct: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Correct',
        default: null,
        description: 'Indicator of the better machine (left = 1, right = 0).'
      },
      arcade_outcomes: {
        type: jsPsych.plugins.parameterType.INT,
        array: true,
        pretty_name: 'Arcade outcomes',
        description: 'Number of points awarded for each machine if chosen.'
      },
      arcade_colors: {
        type: jsPsych.plugins.parameterType.HTML_STRING,
        array: true,
        pretty_name: 'Arcade colors',
        description: 'Hex color codes for left/right arcade machines.',
        default: ['blue', 'red']
      },
      valid_responses_s2: {
        type: jsPsych.plugins.parameterType.KEYCODE,
        array: true,
        pretty_name: 'Valid responses',
        default: [37, 39],
        description: 'The keys the subject is allowed to press to respond during the second stage.'
      },
      choice_duration: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Choice duration',
        default: null,
        description: 'How long to listen for responses before trial ends.'
      },
      feedback_duration: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Trial duration',
        default: 1500,
        description: 'How long to show feedback before it ends.'
      }
    }
  }

  plugin.trial = function(display_element, trial) {

    // ---------------------------------- //
    // Section 1: Define HTML             //
    // ---------------------------------- //

    // Define HTML
    var new_html = '';

    // Insert CSS
    new_html += `<style>
    body {
      height: 100vh;
      max-height: 100vh;
      overflow: hidden;
      position: fixed;
    }
    </style>`;

    // Start task wrapper.
    new_html += '<div class="arcade-wrap">';

    // Start arcade container.
    new_html += '<div class="arcade-grid">';

    // Insert trial header.
    new_html += '<div class="free-choice-header"></div>';

    // Iteratively draw arcades.
    for (let i=0; i < 2; i++) {

      // Define metadata.
      const side = (i == 0) ? "left" : "right";

      // Start arcade container.
      new_html += `<div class="arcade-item" id="arcade-item-${side}" side="${side}">`;

      // Start arcade machine.
      new_html += `<div class="arcade-machine" id="arcade-${side}">`;

      // Draw arcade top.
      new_html += '<div class="shadow"></div>';
      new_html += '<div class="arcade-top">';
      for (let j=0; j<3; j++) {
        new_html += `<div class="arcade-stripe" style="background-color: ${trial.arcade_colors[i]}"></div>`;
      }
      new_html += '</div>';

      // Draw arcade screen.
      new_html += '<div class="screen-container"><div class="shadow"></div>';
      new_html += `<div class="screen" id="screen-${side}"><div class="screen-display"></div></div>`;

      // Draw arcade board.
      new_html += '<div class="joystick"><div class="stick"></div></div></div>';
      new_html += '<div class="board">';
      for (let j=0; j<3; j++) {
        new_html += `<div class="button" style="background-color: ${trial.arcade_colors[i]}"></div>`;
      }
      new_html += '</div>';

      // Draw arcade bottom.
      new_html += '<div class="arcade-bottom">';
      for (let j=0; j<3; j++) {
        new_html += `<div class="arcade-stripe" style="background-color: ${trial.arcade_colors[i]}"></div>`;
      }
      new_html += '</div>';

      // Finish arcade machine / container.
      new_html += '</div></div>';

    }

    // Insert free choice footer.
    new_html += '<div class="free-choice-footer">';
    new_html += '</div>';

    // Close arcade container.
    new_html += '</div>';

    // Close arcade-wrapper.
    new_html += '</div>'

    // Display HTML.
    display_element.innerHTML = new_html;

    // ---------------------------------- //
    // Section 2: jsPsych Functions       //
    // ---------------------------------- //

    // Preallocate space
    var response = {
      stage_1_key: null,
      stage_1_choice: null,
      stage_1_rt: null,
      stage_2_key: null,
      stage_2_rt: null,
      stage_2_choice: null,
    }

    // function to handle responses by the subject
    var after_second_response = function(info) {

      // Kill all setTimeout handlers.
      jsPsych.pluginAPI.clearAllTimeouts();
      jsPsych.pluginAPI.cancelAllKeyboardResponses();

      // Record responses.
      response.stage_2_key = info.key;
      response.stage_2_rt = info.rt;
      if (response.stage_2_key == trial.valid_responses_s2[0]) {
        response.stage_2_choice = 1;
      } else {
        response.stage_2_choice = 0;
      }

      // Define bonus.
      if (response.stage_1_choice == 0) {
        var bonus = `<br><small>(+${trial.bonus_offer})</small>`;
      } else {
        var bonus = '';
      }

      // Define next-stage features.
      if ( response.stage_2_choice == 1 ) {
        display_element.querySelector('#arcade-right').setAttribute('stage', '3')
        display_element.querySelector('#screen-right').innerHTML = '';
        display_element.querySelector('#screen-left').innerHTML = `<div class="screen-display"></div><div class="outcome">+${trial.arcade_outcomes[0]}${bonus}</div>`;
        response.stage_3_outcome = trial.arcade_outcomes[0];
      } else {
        display_element.querySelector('#arcade-left').setAttribute('stage', '3')
        display_element.querySelector('#screen-left').innerHTML = '';
        display_element.querySelector('#screen-right').innerHTML = `<div class="screen-display"></div><div class="outcome">+${trial.arcade_outcomes[1]}${bonus}</div>`;
        response.stage_3_outcome = trial.arcade_outcomes[1];
      }

      jsPsych.pluginAPI.setTimeout(function() {
        end_trial();
      }, trial.feedback_duration);

    };

    // Function to end trial when it is time
    var end_trial = function() {

      // Kill any remaining setTimeout handlers
      jsPsych.pluginAPI.clearAllTimeouts();
      jsPsych.pluginAPI.cancelAllKeyboardResponses();

      // Gather the data to store for the trial
      var trial_data = {
        "offer": trial.bonus_offer,
        "arcade_color_L": trial.arcade_colors[0],
        "arcade_color_R": trial.arcade_colors[1],
        "arcade_outcome_L": trial.arcade_outcomes[0],
        "arcade_outcome_R": trial.arcade_outcomes[1],
        "correct": trial.correct,
        "stage_1_key": response.stage_1_key,
        "stage_1_choice": response.stage_1_choice,
        "stage_1_rt": response.stage_1_rt,
        "stage_2_key": response.stage_2_key,
        "stage_2_choice": response.stage_2_choice,
        "stage_2_rt": response.stage_2_rt,
        "stage_3_outcome": response.stage_3_outcome,
        "accuracy": ((trial.correct == response.stage_2_choice) ? 1 : 0)
      };

      // Clear the display
      display_element.innerHTML = '';

      // Move on to the next trial
      jsPsych.finishTrial(trial_data);

    };

    // Define next-stage features.
    if ( trial.correct == null ) {
      display_element.querySelector('#screen-left').innerHTML += '<h2>PRESS<br>LEFT</h2>';
      display_element.querySelector('#screen-right').innerHTML += '<h2>PRESS<br>RIGHT</h2>';
    } else if ( trial.correct == 1 ) {
      display_element.querySelector('#arcade-right').style['opacity'] = 0.5;
      display_element.querySelector('#screen-right').innerHTML = '';
      display_element.querySelector('#screen-left').innerHTML += '<h2>PRESS<br>LEFT</h2>';
    } else {
      display_element.querySelector('#arcade-left').style['opacity'] = 0.5;
      display_element.querySelector('#screen-left').innerHTML  = '';
      display_element.querySelector('#screen-right').innerHTML += '<h2>PRESS<br>RIGHT</h2>';
    }

    // Initialize first stage keyboardListener.
    var keyboardListener = "";
    setTimeout(function() {
      keyboardListener = jsPsych.pluginAPI.getKeyboardResponse({
        callback_function: after_second_response,
        valid_responses: trial.valid_responses_s2,
        rt_method: 'performance',
        persist: false,
        allow_held_key: false
      });
    }, 0);    // No pause before keyboardListener.

  };

  return plugin;

})();
