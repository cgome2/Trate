package Trate::Lib::Vehiculo;

#########################################################
#Vehiculo - Clase Vehiculo								#
#                                                       #
#Autor: Ramses                                          #
#Fecha: Octubre, 2018                                   #
#Revision: 1.0                                          #
#                                                       #
#########################################################

use strict;
use Trate::Lib::RemoteExecutor;
use Trate::Lib::Constants qw(DEFAULT_FLEET_ID DEFAULT_DEPT_ID);

sub new
{
	my $self = {};
	$self->{NAME} = undef;
	$self->{STRING} = undef;
	$self->{TYPE} = undef;
	$self->{ID} = undef;
	$self->{STATUS} = undef;						# 1. inactivo 2. activo
	$self->{RULE} = undef;							
	$self->{HARDWARE_TYPE} = undef;
	$self->{PUMP} = 0;
	$self->{EMPLOYEE_TYPE} = undef;
	$self->{PLATE} = undef;
	$self->{MODEL_ID} = 0;
	$self->{YEAR} = 0;
	$self->{CAPACITY} = 0.0;
	$self->{CONSUMPTION} = 0.0;
	$self->{ODOMETER} = 0.0;
	$self->{CUST_ID} = '';
	$self->{ADDRESS} = '';
	$self->{FLEET_ID} = DEFAULT_FLEET_ID;
	$self->{DEPT_ID} = DEFAULT_DEPT_ID;
	$self->{ACCTYP} = 0;
	$self->{AVAILABLE_AMOUNT} = 0.0;
	$self->{UPDATE_TIMESTAMP} = "datetime'NOW()'";
	$self->{FCC_BOS_CLEARED} = 0;
	$self->{USE_PIN_CODE} = 0;
	$self->{PIN_CODE} = 0;
	$self->{AUTH_PIN_FROM} = undef;
	$self->{NR_PIN_RETRIES} = 0;
	$self->{BLOCK_IF_PIN_RETRIES_FAIL} = 0;
	$self->{OPOS_PROMPT_FOR_PLATE} = 0;
	$self->{OPOS_PROMPT_FOR_ODOMETER} = 0;
	$self->{DO_ODO_REASONABILITY_CHECK} = undef;
	$self->{MAX_ODO_DELTA_ALLOWED} = 0;
	$self->{NR_ODO_RETRIES} = 0;
	$self->{DRIVER_ID_TYPE_REQUIRED} = undef;
	$self->{PRICE_LIST_ID} = 0;
	$self->{DAY_VOLUME} = 0.0;
	$self->{WEEK_VOLUME} = 0.0;
	$self->{MONTH_VOLUME} = 0.0;
	$self->{DAY_MONEY} = 0.0;
	$self->{WEEK_MONEY} = 0.0;
	$self->{MONTH_MONEY} = 0.0;
	$self->{DAY_VISITS} = 0;
	$self->{WEEK_VISITS} = 0;
	$self->{MONTH_VISITS} = 0;
	$self->{SENT_TO_DHO} = 0;
	$self->{SENT_TO_FHO} = 0;
	$self->{AUTTYP} = undef;
	$self->{ENGINE_HOURS} = 0.0;
	$self->{ORIGINAL_ENGINE_HOURS} = 0.0;
	$self->{TARGET_ENGINE_HOURS} = 0.0;
	$self->{PRICE_LIST} = 'NULL';
	$self->{NEED_HO_UPDATE} = 0;
	$self->{OPOS_PROMPT_FOR_ENGINE_HOURS} = 0;
	$self->{ADDRESS2} = undef;
	$self->{CITY} = undef;
	$self->{STATE} = undef;
	$self->{ZIP} = undef;
	$self->{PHONE} = undef;
	$self->{USER_DATA1} = undef;
	$self->{USER_DATA2} = undef;
	$self->{USER_DATA3} = undef;
	$self->{USER_DATA4} = undef;
	$self->{USER_DATA5} = undef;
	$self->{START_ODOMETER} = 0.0;
	$self->{CONSUMPTION2} = 0.0;
	$self->{IS_BURNED} = undef;
	$self->{VIU_SERIAL} = undef;
	$self->{ALLOW_ID_REPLACEMENT} = 0;
	$self->{NUM_OF_STRINGS} = 1;
	$self->{STRING2} = undef;
	$self->{STRING3} = undef;
	$self->{STRING4} = undef;
	$self->{STRING5} = undef;
	$self->{OPOS_PLATE_CHECK_TYPE} = undef;
	$self->{NR_PLATE_RETRIES} = 0;
	$self->{BLOCK_IF_PLATE_RETRIES_FAIL} = 0;
	$self->{CHASSIS_NUMBER} = undef;
	$self->{SENT_TO_OLIC} = 0;
	$self->{ISSUED_DATE} = undef;
	$self->{LAST_USED} = undef;
	$self->{DISABLE_VIU_TWO_STAGE} = 0;			# 1. Desactivar doble autorizacion 2. Desactivar doble autorizacion
	$self->{PROMPT_ALWAYS_FOR_VIU} = 1;			# 1. Requiere doble autorizacion 2. No requiere doble autorizacion
	$self->{DISCOVERED} = 0;
	$self->{EXPIRE} = 0;
	$self->{EXPIRE_DATE} = '0000';
	$self->{YEAR_VOLUME} = 0.0;
	$self->{YEAR_MONEY} = 0.0;
	$self->{SENT_TO_CLIENT} = 0;
	$self->{DO_EH_REASONABILITY_CHECK} = undef;
	$self->{MAX_EH_DELTA_ALLOWED} = 0;
	$self->{NR_EH_RETRIES} = 0;
	$self->{REJECT_IF_EH_CHECK_FAILS} = 0;
	$self->{DEPOSIT_DATE} = '';
	$self->{CASH_ON_HAND} = 0.0;
	$self->{MAX_CASH_ALLOWED} = 0.0;
	$self->{BLOCK_FUELING} = 0;
	$self->{ADD_DP_APPROVED} = 0;
	$self->{ADD_DP_APPROVAL_DATE} = '';
	$self->{ADD_DP_COMPLETION_DATE} = '';
	$self->{REJECT_IF_ODM_CHECK_FAILS} = 0;
	$self->{ROUTE_PROMPT} = 0;
	$self->{PRESSURE_LEVEL} = 0;
	$self->{ATTENDANT_REQUIRED} = 0;
	$self->{NOTIFY_EXPIRE} = 0;
	$self->{NOTIFICATION_DAYS} = 0;
	$self->{MAX_CASH_ALLOWED_AT_NIGHT} = 0.0;
	$self->{HIGH_CASH_ALLOWED} = 0.0;
	$self->{HIGH_CASH_ALLOWED_AT_NIGHT} = 0.0;
	$self->{DAYTIME_START} = 0;
	$self->{NIGHTTIME_START} = 0;
	$self->{SHIFT_INSTANCE_ID} = 0;
	$self->{PROMPT_FOR_JOBCODE} = 0;

	bless($self);
	return $self;	
}

sub name {
        my ($self) = shift;
        if (@_) { $self->{NAME} = shift }        
        return $self->{NAME};
}

sub string {
        my ($self) = shift;
        if (@_) { $self->{STRING} = shift }        
        return $self->{STRING};
}

sub type {
        my ($self) = shift;
        if (@_) { $self->{TYPE} = shift }        
        return $self->{TYPE};
}

sub id {
        my ($self) = shift;
        if (@_) { $self->{id} = shift }        
        return $self->{id};
}

sub status {
        my ($self) = shift;
        if (@_) { $self->{STATUS} = shift }        
        return $self->{STATUS};
}

sub rule {
        my ($self) = shift;
        if (@_) { $self->{RULE} = shift }        
        return $self->{RULE};
}

sub hardwareType {
        my ($self) = shift;
        if (@_) { $self->{HARDWARE_TYPE} = shift }        
        return $self->{STATUS};
}

sub pump {
        my ($self) = shift;
        if (@_) { $self->{PUMP} = shift }        
        return $self->{PUMP};
}

sub employeeType {
        my ($self) = shift;
        if (@_) { $self->{EMPLOYEE_TYPE} = shift }        
        return $self->{EMPLOYEE_TYPE};
}

sub plate {
        my ($self) = shift;
        if (@_) { $self->{PLATE} = shift }        
        return $self->{PLATE};
}

sub modelId {
        my ($self) = shift;
        if (@_) { $self->{MODEL_ID} = shift }        
        return $self->{MODEL_ID};
}

sub year {
        my ($self) = shift;
        if (@_) { $self->{YEAR} = shift }        
        return $self->{YEAR};
}

sub capacity {
        my ($self) = shift;
        if (@_) { $self->{CAPACITY} = shift }        
        return $self->{CAPACITY};
}

sub consumption {
        my ($self) = shift;
        if (@_) { $self->{CONSUMPTION} = shift }        
        return $self->{CONSUMPTION};
}

sub odometer {
        my ($self) = shift;
        if (@_) { $self->{ODOMETER} = shift }        
        return $self->{ODOMETER};
}

sub fleetId {
        my ($self) = shift;
        if (@_) { $self->{FLEET_ID} = shift }        
        return $self->{FLEET_ID};
}

sub deptId {
        my ($self) = shift;
        if (@_) { $self->{DEPT_ID} = shift }        
        return $self->{DEPT_ID};
}

sub authPinFrom {
        my ($self) = shift;
        if (@_) { $self->{AUTH_PIN_FROM} = shift }        
        return $self->{AUTH_PIN_FROM};
}

sub doOdoReasonabilityCheck {
        my ($self) = shift;
        if (@_) { $self->{DO_ODO_REASONABILITY_CHECK} = shift }        
        return $self->{DO_ODO_REASONABILITY_CHECK};
}

sub driverIdTypeRequired {
        my ($self) = shift;
        if (@_) { $self->{DRIVER_ID_TYPE_REQUIRED} = shift }        
        return $self->{DRIVER_ID_TYPE_REQUIRED};
}

sub auttyp {
        my ($self) = shift;
        if (@_) { $self->{AUTTYP} = shift }        
        return $self->{AUTTYP};
}

sub isBurned {
        my ($self) = shift;
        if (@_) { $self->{IS_BURNED} = shift }        
        return $self->{IS_BURNED};
}

sub viuSerial {
        my ($self) = shift;
        if (@_) { $self->{VIU_SERIAL} = shift }        
        return $self->{VIU_SERIAL};
}

sub oposPlateCheckType {
        my ($self) = shift;
        if (@_) { $self->{OPOS_PLATE_CHECK_TYPE} = shift }        
        return $self->{OPOS_PLATE_CHECK_TYPE};
}

sub chassisNumber {
        my ($self) = shift;
        if (@_) { $self->{CHASSIS_NUMBER} = shift }        
        return $self->{CHASSIS_NUMBER};
}

sub issuedDate {
        my ($self) = shift;
        if (@_) { $self->{ISSUED_DATE} = shift }        
        return $self->{ISSUED_DATE};
}

sub dissableViuTwoStage {
        my ($self) = shift;
        if (@_) { $self->{DISABLE_VIU_TWO_STAGE} = shift }        
        return $self->{DISABLE_VIU_TWO_STAGE};
}

sub promptAlwaysForViu {
        my ($self) = shift;
        if (@_) { $self->{PROMPT_ALWAYS_FOR_VIU} = shift }        
        return $self->{PROMPT_ALWAYS_FOR_VIU};
}

sub doEhReasonabilityCheck {
        my ($self) = shift;
        if (@_) { $self->{DO_EH_REASONABILITY_CHECK} = shift }        
        return $self->{DO_EH_REASONABILITY_CHECK};
}

sub notificationDays {
        my ($self) = shift;
        if (@_) { $self->{NOTIFICATION_DAYS} = shift }        
        return $self->{NOTIFICATION_DAYS};
}

sub discovered {
        my ($self) = shift;
        if (@_) { $self->{DISCOVERED} = shift }        
        return $self->{DISCOVERED};
}

sub createVehicleOrcu {
	my $self = shift;
	my $remex = Trate::Lib::RemoteExecutor->new();
	my $query = "INSERT INTO means (NAME, string, TYPE, id, status, rule, hardware_type, pump, employee_type, plate, model_id, YEAR, capacity, consumption, odometer, fleet_id, dept_id, update_timestamp, auth_pin_from, do_odo_reasonability_check, driver_id_type_required, auttyp, is_burned, viu_serial, opos_plate_check_type, chassis_number, issued_date, disable_viu_two_stage, prompt_always_for_viu, do_eh_reasonability_check, notification_days) VALUES ('" . 
										$self->{NAME} . "','" .
										$self->{STRING} . "','" .
										$self->{TYPE} . "','" .
										$self->{ID} . "','" .
										$self->{STATUS} . "','" .
										$self->{RULE} . "','" .
										$self->{HARDWARE_TYPE} . "','" .
										$self->{PUMP} . "','" .
										$self->{EMPLOYEE_TYPE} . "','" .
										$self->{PLATE} . "','" .
										$self->{MODEL_ID} . "','" .
										$self->{YEAR} . "','" .
										$self->{CAPACITY} . "','" .
										$self->{CONSUMPTION} . "','" .
										$self->{ODOMETER} . "','" .
										$self->{FLEET_ID} . "','" .
										$self->{DEPT_ID} . "'," .
										$self->{UPDATE_TIMESTAMP} . ",'" .
										$self->{AUTH_PIN_FROM} . "','" .
										$self->{DO_ODO_REASONABILITY_CHECK} . "','" .
										$self->{DRIVER_ID_TYPE_REQUIRED} . "','" .
										$self->{AUTTYP} . "','" .
										$self->{IS_BURNED} . "','" .
										$self->{VIU_SERIAL} . "','" .
										$self->{OPOS_PLATE_CHECK_TYPE} . "','" .
										$self->{CHASSIS_NUMBER} . "','" .
										$self->{ISSUED_DATE} . "','" .
										$self->{DISABLE_VIU_TWO_STAGE} . "','" .
										$self->{PROMPT_ALWAYS_FOR_VIU} . "','" .
										$self->{DO_EH_REASONABILITY_CHECK} . "','" .
										$self->{NOTIFICATION_DAYS} . "','" .
										$self->{DISCOVERED} . "')";
	$remex->remoteQuery($query);
	return 1;	
}

sub assignRuleToVehicleOrcu() {
	my $self = shift;
	my $remex = Trate::Lib::RemoteExecutor->new();
	my $query = "UPDATE means SET rule='" . $self->{RULE} . "' WHERE NAME='" . $self->{NAME} . "'";
	system("echo $query >> /tmp/logfile.log");
	$remex->remoteQuery($query);
	return 1;	
}


#ssh root@192.168.1.105 -p22 'sqlite3 /usr/local/orpak/BOS/DB/DATA.DB "update means set rule=\"200000001\" where NAME=\"AutoTag\";"'

1;
#EOF