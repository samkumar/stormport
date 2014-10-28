module FireStormSensorsP
{
    provides
    {
        interface FSAccelerometer;
        interface FSIlluminance;
        interface SplitControl;
    }
    uses
    {
        interface Timer<TMilli>;
        interface I2CPacket<TI2CBasicAddr>;
        interface GeneralIO as ENSEN;
    }
}
implementation
{

    #define ACCEL 0x1E
    #define TEMP 0x40
    #define LI 0x44

    uint8_t i2c_read_reg(uint8_t devaddr, uint8_t regaddr)
    {
        uint8_t tmp = regaddr;
        error_t rv;
        rv = call I2CPacket.write(I2C_START, devaddr, 1, &tmp);
        if (rv != SUCCESS)
        {
            printf ("I2C write failed\n");
            return 0;
        }
        call I2CPacket.read(I2C_START | I2C_STOP, devaddr, 1, &tmp);
        if (rv != SUCCESS)
        {
            printf ("I2C red failed\n");
            return 0;
        }
        return tmp;
    }
    bool i2c_probe(uint8_t devaddr)
    {
        error_t rv;
        rv = call I2CPacket.write(I2C_START | I2C_STOP, devaddr, 0, &devaddr);
        return rv == SUCCESS;
    }
    void i2c_write_reg(uint8_t devaddr, uint8_t regaddr, uint8_t val)
    {
        uint8_t tmp[2] = {regaddr, val};
        error_t rv;
        rv = call I2CPacket.write(I2C_START | I2C_STOP, devaddr, 2, &tmp[0]);
        if (rv != SUCCESS)
        {
            printf ("I2C write failed\n");
        }
    }
    void i2c_write_reg16(uint8_t devaddr, uint8_t regaddr, uint16_t val)
    {
        uint8_t tmp[3] = {regaddr, val >>8, val};
        error_t rv;
        rv = call I2CPacket.write(I2C_START | I2C_STOP, devaddr, 3, &tmp[0]);
        if (rv != SUCCESS)
        {
            printf ("I2C write failed\n");
        }
    }
    uint16_t i2c_read_reg16(uint8_t devaddr, uint8_t regaddr)
    {
        uint8_t tmp[2] = {regaddr, 0};
        uint32_t t;
        int16_t rvi;
        error_t rv;
        rv = call I2CPacket.write(I2C_START, devaddr, 1, &tmp[0]);
        if (rv != SUCCESS)
        {
            printf ("I2C write failed\n");
            return 0;
        }
        call I2CPacket.read(I2C_START | I2C_STOP, devaddr, 2, &tmp[0]);
        if (rv != SUCCESS)
        {
            printf ("I2C red failed\n");
            return 0;
        }
        t = (tmp[0] << 8)  + tmp[1];
        rvi = (int16_t) t;
        return rvi;
    }

    #define ACCEL_STATUS 0x00
    #define ACCEL_WHOAMI 0x0D
    #define ACCEL_XYZ_DATA_CFG 0x0E
    #define ACCEL_CTRL_REG1 0x2A
    #define ACCEL_M_CTRL_REG1 0x5B
    #define ACCEL_M_CTRL_REG2 0x5C
    #define ACCEL_WHOAMI_VAL 0xC7

    typedef struct
    {
        int16_t acc_x;
        int16_t acc_y;
        int16_t acc_z;
        int16_t mag_x;
        int16_t mag_y;
        int16_t mag_z;
    } acc_data_t;

    void config_accel()
    {
        uint32_t tmp;

        tmp = i2c_read_reg(ACCEL, ACCEL_WHOAMI);
        if (tmp != ACCEL_WHOAMI_VAL)
        {
            printf("ACCELEROMETER did not ack properly\n");
            return;
        }

        //Place into standby
        i2c_write_reg(ACCEL, ACCEL_CTRL_REG1, 0x00);

        //cfg magnetometer (page 32 of datasheet)
        i2c_write_reg(ACCEL, ACCEL_M_CTRL_REG1, 0b00011111);
        i2c_write_reg(ACCEL, ACCEL_M_CTRL_REG2, 0b00100000);

        //cfg accel range
        i2c_write_reg(ACCEL, ACCEL_XYZ_DATA_CFG, 0b00000001);
        i2c_write_reg(ACCEL, ACCEL_CTRL_REG1, 0x0D);

    }

    void read_accel(acc_data_t *dat)
    {
        uint8_t addr = ACCEL_STATUS;
        uint8_t buf [13];
        error_t rv;
        rv = call I2CPacket.write(I2C_START, ACCEL, 1, &addr);
        if (rv != SUCCESS)
        {
            printf ("I2C write failed\n");
            return;
        }
        call I2CPacket.read(I2C_START | I2C_STOP, ACCEL, 13, &buf[0]);
        if (rv != SUCCESS)
        {
            printf ("I2C red failed\n");
            return;
        }
        dat->acc_x = (int16_t)(((uint32_t)buf[1] << 8) + buf[2]);
        dat->acc_y = (int16_t)(((uint32_t)buf[3] << 8) + buf[4]);
        dat->acc_z = (int16_t)(((uint32_t)buf[5] << 8) + buf[6]);
        dat->mag_x = (int16_t)(((uint32_t)buf[7] << 8) + buf[8]);
        dat->mag_y = (int16_t)(((uint32_t)buf[9] << 8) + buf[10]);
        dat->mag_z = (int16_t)(((uint32_t)buf[11] << 8) + buf[12]);
    }

    command error_t SplitControl.start()
    {
        call ENSEN.makeOutput();
        call ENSEN.clr();
        printf("Enabling sensor rail\n");
        i2c_write_reg(LI, 0x00, 0b10100000); //enable
        i2c_write_reg(LI, 0x01, 0b00000011); //enable
        config_accel();
        call Timer.startPeriodic(1000);
        printf("Init complete\n");
        signal SplitControl.startDone(SUCCESS);
        return SUCCESS;
    }

    command error_t SplitControl.stop()
    {
        return FAIL;
    }
    acc_data_t acdat;
    uint16_t li;
    event void Timer.fired()
    {
        uint32_t x;
        read_accel(&acdat);

        x = i2c_read_reg(LI, 0x03);
        x <<= 8;
        x |= i2c_read_reg(LI, 0x02);
        li = (uint16_t) x;

        #ifdef PRINT_LOCAL_SENSORS
        printf ("ACCELEROMETER: \n");
        printf ("    X= %d \n", (acdat.acc_x));
        printf ("    Y= %d \n", (acdat.acc_y));
        printf ("    Z= %d \n\n", (acdat.acc_z));
        printf ("MAGNETOMETER: \n");
        printf ("    X= %d \n", (acdat.mag_x));
        printf ("    Y= %d \n", (acdat.mag_y));
        printf ("    Z= %d \n\n", (acdat.mag_z));
        printf ("LIGHT INTENSITY:\n");
        printf ("  LUX= %d\n\n", li);
        #endif
    }

    async event void I2CPacket.readDone(error_t error, uint16_t addr, uint8_t length, uint8_t* data)
    {

    }
    async event void I2CPacket.writeDone(error_t error, uint16_t addr, uint8_t length, uint8_t* data)
    {

    }

    async command uint32_t FSIlluminance.getVisibleLux()
    {
        return li;
    }
    async command uint16_t FSAccelerometer.getMagnX()
    {
        return acdat.mag_x;
    }
    async command uint16_t FSAccelerometer.getMagnY()
    {
        return acdat.mag_y;
    }
    async command uint16_t FSAccelerometer.getMagnZ()
    {
        return acdat.mag_z;
    }
    async command uint16_t FSAccelerometer.getAccelX()
    {
        return acdat.acc_x;
    }
    async command uint16_t FSAccelerometer.getAccelY()
    {
        return acdat.acc_y;
    }
    async command uint16_t FSAccelerometer.getAccelZ()
    {
        return acdat.acc_z;
    }




}