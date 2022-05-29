class EventHandler;
    typedef enum {lp_ctrl, lp_data, phymstr, ctrlupd, phyupd} transaction_e;

    static event lp_ctrl_start;
    static event lp_ctrl_finish;

    static event lp_data_start;
    static event lp_data_finish;

    static event phymstr_start;
    static event phymstr_finish;

    static event ctrlupd_start;
    static event ctrlupd_finish;

    static event phyupd_start;
    static event phyupd_finish;

    //*********************************************//
    static task trigger_event(ref event e);
        ->e;
    endtask

    static task wait_for_event(ref event e);
        wait(e.triggered);
    endtask

    // *************** trigger events *************** //
    static task automatic start_transaction(transaction_e tr);
        case (tr)
            lp_ctrl:    trigger_event(lp_ctrl_start);
            lp_data:    trigger_event(lp_data_start);
            phymstr:    trigger_event(phymstr_start);
            ctrlupd:    trigger_event(ctrlupd_start);
            phyupd:     trigger_event(phyupd_start);
        endcase
    endtask

    static task automatic end_transaction(transaction_e tr);
        case (tr)
            lp_ctrl:    trigger_event(lp_ctrl_finish);
            lp_data:    trigger_event(lp_data_finish);
            phymstr:    trigger_event(phymstr_finish);
            ctrlupd:    trigger_event(ctrlupd_finish);
            phyupd:     trigger_event(phyupd_finish);
        endcase
    endtask

    // *************** wait events *************** //
    static task automatic wait_for_transaction_start(transaction_e tr);
        case (tr)
            lp_ctrl:    wait_for_event(lp_ctrl_start);
            lp_data:    wait_for_event(lp_data_start);
            phymstr:    wait_for_event(phymstr_start);
            ctrlupd:    wait_for_event(ctrlupd_start);
            phyupd:     wait_for_event(phyupd_start);
        endcase
    endtask

    static task automatic wait_for_transaction_finish(transaction_e tr);
        case (tr)
            lp_ctrl:    wait_for_event(lp_ctrl_finish);
            lp_data:    wait_for_event(lp_data_finish);
            phymstr:    wait_for_event(phymstr_finish);
            ctrlupd:    wait_for_event(ctrlupd_finish);
            phyupd:     wait_for_event(phyupd_finish);
        endcase
    endtask

    static task automatic wait_for_transaction(transaction_e tr);
        wait_for_transaction_start(tr);
        wait_for_transaction_finish(tr);
    endtask

endclass