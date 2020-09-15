#include "interconnect.h"
#include "adpll.h"

// Memory map
#include "adpll_mem_map.h"

//base address
int adpll;

void adpll_init(int base_address) {
  // capture base address
  adpll = base_address;

  // pulse software reset
  adpll_soft_rst();
}

int adpll_lock(void) {
  return (IO_GET(adpll, ADPLL_LOCK));
}

int adpll_sat(void) {
  return (IO_GET(adpll, ADPLL_SAT));
}

void adpll_set_soft_rst(char value) {
  IO_SET(adpll, ADPLL_SOFT_RST, (int)value);
}

void adpll_set_fcw(char value) {
  IO_SET(adpll, FCW, (int)value);
}

void adpll_set_mode(char value) {
  IO_SET(adpll, ADPLL_MODE, (int)value);
}

void adpll_set_en(char value) {
  IO_SET(adpll, ADPLL_EN, (int)value);
}

void adpll_set_alpha_l(char value) {
  IO_SET(adpll, ALPHA_L, (int)value);
}

void adpll_set_alpha_m(char value) {
  IO_SET(adpll, ALPHA_M, (int)value);
}

void adpll_set_alpha_s_rx(char value) {
  IO_SET(adpll, ALPHA_S_RX, (int)value);
}

void adpll_set_alpha_s_tx(char value) {
  IO_SET(adpll, ALPHA_S_TX, (int)value);
}

void adpll_set_beta(char value) {
  IO_SET(adpll, BETA, (int)value);
}

void adpll_set_lambda_rx(char value) {
  IO_SET(adpll, LAMBDA_RX, (int)value);
}

void adpll_set_lambda_tx(char value) {
  IO_SET(adpll, LAMBDA_TX, (int)value);
}

void adpll_set_iir_n_rx(char value) {
  IO_SET(adpll, IIR_N_RX, (int)value);
}

void adpll_set_iir_n_tx(char value) {
  IO_SET(adpll, IIR_N_TX, (int)value);
}

void adpll_set_fcw_mod(char value) {
  IO_SET(adpll, FCW_MOD, (int)value);
}

void adpll_set_dco_c_l_word_test(char value) {
  IO_SET(adpll, DCO_C_L_WORD_TEST, (int)value);
}

void adpll_set_dco_c_m_word_test(char value) {
  IO_SET(adpll, DCO_C_M_WORD_TEST, (int)value);
}

void adpll_set_dco_c_s_word_test(char value) {
  IO_SET(adpll, DCO_C_S_WORD_TEST, (int)value);
}

void adpll_set_dco_pd_test(char value) {
  IO_SET(adpll, DCO_PD_TEST, (int)value);
}

void adpll_set_tdc_pd_test(char value) {
  IO_SET(adpll, TDC_PD_TEST, (int)value);
}

void adpll_set_tdc_pd_inj_test(char value) {
  IO_SET(adpll, TDC_PD_INJ_TEST, (int)value);
}

void adpll_set_tdc_ctr_freq(char value) {
  IO_SET(adpll, TDC_CTR_FREQ, (int)value);
}

void adpll_set_dco_osc_gain(char value) {
  IO_SET(adpll, DCO_OSC_GAIN, (int)value);
}

void adpll_config(char fcw, char mode,
                  char alpha_l, char alpha_m, char alpha_s_rx, char alpha_s_tx,
                  char beta,
                  char lambda_rx, char lambda_tx,
                  char iir_n_rx, char iir_n_tx,
                  char FCW_mod,
                  char dco_c_l_word_test, char dco_c_m_word_test, char dco_c_s_word_test,
                  char dco_pd_test, char dco_osc_gain,
                  char tdc_pd_test, char tdc_pd_inj_test, char tdc_ctr_freq) {

  adpll_set_fcw(fcw);
  adpll_set_mode(mode);
  adpll_set_alpha_l(alpha_l);
  adpll_set_alpha_m(alpha_m);
  adpll_set_alpha_s_rx(alpha_s_rx);
  adpll_set_alpha_s_tx(alpha_s_tx);
  adpll_set_beta(beta);
  adpll_set_lambda_rx(lambda_rx);
  adpll_set_lambda_tx(lambda_tx);
  adpll_set_iir_n_rx(iir_n_rx);
  adpll_set_iir_n_tx(iir_n_tx);
  adpll_set_fcw_mod(FCW_mod);
  adpll_set_dco_c_l_word_test(dco_c_l_word_test);
  adpll_set_dco_c_m_word_test(dco_c_m_word_test);
  adpll_set_dco_c_s_word_test(dco_c_s_word_test);
  adpll_set_dco_pd_test(dco_pd_test);
  adpll_set_tdc_pd_test(tdc_pd_test);
  adpll_set_tdc_pd_inj_test(tdc_pd_inj_test);
  adpll_set_tdc_ctr_freq(tdc_ctr_freq);
  adpll_set_dco_osc_gain(dco_osc_gain);

  return;
}
