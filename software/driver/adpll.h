// Functions

// Initialize ADPLL
void adpll_init(int base_address);

// Get lock
int adpll_lock(void);

// Get sat
int adpll_sat(void);

// Set software reset
void adpll_set_soft_rst(char value);

// Set FCW
void adpll_set_fcw(int value);

// Set mode
void adpll_set_mode(char value);

// Set enable
void adpll_set_en(char value);

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
void adpll_set_tdc_ctr_freq(char value);

// Set DCO osc gain
void adpll_set_dco_osc_gain(char value);

// Software reset
#define adpll_soft_rst() ({\
      adpll_set_soft_rst(1);\
      adpll_set_soft_rst(0);\
    })

// Enable ADPLL
#define adpll_enable() adpll_set_en(1)

// Disable ADPLL
#define adpll_disable() adpll_set_en(0)

void adpll_config(int fcw, char mode,
                  char alpha_l, char alpha_m, char alpha_s_rx, char alpha_s_tx,
                  char beta,
                  char lambda_rx, char lambda_tx,
                  char iir_n_rx, char iir_n_tx,
                  char FCW_mod,
                  char dco_c_l_word_test, char dco_c_m_word_test, char dco_s_l_word_test,
                  char dco_pd_test, char dco_osc_gain,
                  char tdc_pd_test, char tdc_pd_inj_test, char tdc_ctr_freq);
