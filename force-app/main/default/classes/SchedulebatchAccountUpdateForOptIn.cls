global class SchedulebatchAccountUpdateForOptIn implements Schedulable {
    global void execute(SchedulableContext ctx) {
        batchAccountUpdate bc = new batchAccountUpdate();
        database.executebatch(bc,100);
    }
}