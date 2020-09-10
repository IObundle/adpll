// Memory map
#define ADPLL_ALPHA_L            0
#define ADPLL_ALPHA_M            1
#define ADPLL_ALPHA_S_RX         2
#define ADPLL_ALPHA_S_TX         3
#define ADPLL_BETA               4
#define ADPLL_LAMBDA_RX          5
#define ADPLL_LAMBDA_TX          6
#define ADPLL_IIR_N_RX           7
#define ADPLL_IIR_N_TX           8
#define ADPLL_FCW_MOD            9
#define ADPLL_DCO_C_L_WORD_TEST 10
#define ADPLL_DCO_C_M_WORD_TEST 11
#define ADPLL_DCO_C_S_WORD_TEST 12
#define ADPLL_DCO_PD_TEST       13
#define ADPLL_TDC_PD_TEST       14
#define ADPLL_TDC_PD_INJ_TEST   15
#define ADPLL_CTR_FREQ_TEST     16
#define ADPLL_DCO_OSC_TEST      17
#define ADPLL_SOFT_RST          18

// Functions

// Initialize ADPLL
void adpll_init(int base_address);

// Set alpha l
void adpll_set_alpha_l(char value);

// Set alpha m
void adpll_set_alpha_m(char value);

// Set alpha s RX
void adpll_set_alpha_s_rx(char value);

// Set alpha s TX
void adpll_set_alpha_s_tx(char value);

// Set beta
void adpll_set_beta(char value);

// Set lambda RX
void adpll_set_lambda_rx(char value);

// Set lambda TX
void adpll_set_lambda_tx(char value);

// Set IIR n RX
void adpll_set_iir_n_rx(char value);

// Set IIR n TX
void adpll_set_iir_n_tx(char value);

// Set FCW MOD
void adpll_set_fcw_mod(char value);

// Set DCO c l word test
void adpll_set_dco_c_l_word_test(char value);

// Set DCO c m word test
void adpll_set_dco_c_m_word_test(char value);

// Set DCO c s word test
void adpll_set_dco_c_s_word_test(char value);

// Set DCO PD test
void adpll_set_dco_pd_test(char value);

// Set TDC PD test
void adpll_set_tdc_pd_test(char value);

// Set TDC inj test
void adpll_set_tdc_pd_inj_test(char value);

// Set control frequency test
void adpll_set_ctr_freq_test(char value);

// Set DCO osc test
void adpll_set_dco_osc_test(char value);

// Set software reset
void adpll_set_soft_rst(char value);

// Software reset
#define adpll_soft_rst() {adpll_set_soft_rst(1);\
                          adpll_set_soft_rst(0);}

void adpll_config(char alpha_l, char alpha_m, char alpha_s_rx, char alpha_s_tx,
                  char beta,
                  char lambda_rx, char lambda_tx,
                  char iir_n_rx, char iir_n_tx,
                  char FCW_mod,
                  char dco_c_l_word_test, char dco_c_m_word_test, char dco_s_l_word_test,
                  char dco_pd_test,
                  char tdc_pd_test, char tdc_pd_inj_test);
