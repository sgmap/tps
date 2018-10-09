import '../shared/polyfills';
import Turbolinks from 'turbolinks';
import Chartkick from 'chartkick';
import Highcharts from 'highcharts';
import start from 'better-ujs';

import ActiveStorage from '../shared/activestorage/ujs';

import '../shared/sentry';
import '../shared/autocomplete';
import '../shared/franceconnect';

import '../new_design/spinner';
import '../new_design/dropdown';
import '../new_design/form-validation';
import '../new_design/carto';
import '../new_design/select2';

import '../new_design/champs/linked-drop-down-list';

import { toggleCondidentielExplanation } from '../new_design/avis';
import { scrollMessagerie } from '../new_design/messagerie';
import { showMotivation, motivationCancel } from '../new_design/state-button';
import { toggleChart } from '../new_design/toggle-chart';

// This is the global application namespace where we expose helpers used from rails views
const DS = {
  toggleCondidentielExplanation,
  scrollMessagerie,
  showMotivation,
  motivationCancel,
  toggleChart
};

// Start Rails helpers
Chartkick.addAdapter(Highcharts);
start();
Turbolinks.start();
ActiveStorage.start();

// Expose globals
window.DS = window.DS || DS;
window.Chartkick = Chartkick;
