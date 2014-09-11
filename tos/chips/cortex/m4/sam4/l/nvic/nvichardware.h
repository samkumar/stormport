

//This information cannot be found purely in the sam4l datasheet, you also need to consult the NVID documentation in
//the arm datasheet for armv7
typedef union
{
    uint32_t flat[3];
    struct
    {
        uint32_t hflashc        : 1;
        uint32_t pdca0          : 1;
        uint32_t pdca1          : 1;
        uint32_t pdca2          : 1;
        uint32_t pdca3          : 1;
        uint32_t pdca4          : 1;
        uint32_t pdca5          : 1;
        uint32_t pdca6          : 1;
        uint32_t pdca7          : 1;
        uint32_t pdca8          : 1;
        uint32_t pdca9          : 1;
        uint32_t pdca10         : 1;
        uint32_t pdca11         : 1;
        uint32_t pdca12         : 1;
        uint32_t pdca13         : 1;
        uint32_t pdca14         : 1;
        uint32_t pdca15         : 1;
        uint32_t crccu          : 1;
        uint32_t usbc           : 1;
        uint32_t pevctr         : 1;
        uint32_t pevcov         : 1;
        uint32_t aesa           : 1;
        uint32_t pm             : 1;
        uint32_t scif           : 1;
        uint32_t freqm          : 1;
        uint32_t gpio0          : 1;
        uint32_t gpio1          : 1;
        uint32_t gpio2          : 1;
        uint32_t gpio3          : 1;
        uint32_t gpio4          : 1;
        uint32_t gpio5          : 1;
        uint32_t gpio6          : 1;
        //next word
        uint32_t gpio7          : 1;
        uint32_t gpio8          : 1;
        uint32_t gpio9          : 1;
        uint32_t gpio10         : 1;
        uint32_t gpio11         : 1;
        uint32_t bpm            : 1;
        uint32_t bscif          : 1;
        uint32_t ast_alarm      : 1;
        uint32_t ast_per        : 1;
        uint32_t ast_ovf        : 1;
        uint32_t ast_ready      : 1;
        uint32_t ast_clkready   : 1;
        uint32_t wdt            : 1;
        uint32_t eic1           : 1;
        uint32_t eic2           : 1;
        uint32_t eic3           : 1;
        uint32_t eic4           : 1;
        uint32_t eic5           : 1;
        uint32_t eic6           : 1;
        uint32_t eic7           : 1;
        uint32_t eic8           : 1;
        uint32_t iisc           : 1;
        uint32_t spi            : 1;
        uint32_t tc00           : 1;
        uint32_t tc01           : 1;
        uint32_t tc02           : 1;
        uint32_t tc10           : 1;
        uint32_t tc11           : 1;
        uint32_t tc12           : 1;
        uint32_t twim0          : 1;
        uint32_t twis0          : 1;
        uint32_t twim1          : 1;
        //next word
        uint32_t twis1          : 1;
        uint32_t usart0         : 1;
        uint32_t usart1         : 1;
        uint32_t usart2         : 1;
        uint32_t usart3         : 1;
        uint32_t adcife         : 1;
        uint32_t dacc           : 1;
        uint32_t acifc          : 1;
        uint32_t abdacb         : 1;
        uint32_t trng           : 1;
        uint32_t parc           : 1;
        uint32_t catb           : 1;
        uint32_t reserved0      : 1;
        uint32_t twim2          : 1;
        uint32_t twim3          : 1;
        uint32_t lcdca          : 1;
        uint32_t reserved1      : 17;
    } __attribute__((__packed__)) bits;
} nvic_x_t;

typedef union
{
    uint32_t flat[20];
    struct
    {
        uint32_t reserved0      : 4;
        uint32_t hflashc        : 4;
        uint32_t reserved1      : 4;
        uint32_t pdca0          : 4;
        uint32_t reserved2      : 4;
        uint32_t pdca1          : 4;
        uint32_t reserved3      : 4;
        uint32_t pdca2          : 4;
        uint32_t reserved4      : 4;
        uint32_t pdca3          : 4;
        uint32_t reserved5      : 4;
        uint32_t pdca4          : 4;
        uint32_t reserved6      : 4;
        uint32_t pdca5          : 4;
        uint32_t reserved7      : 4;
        uint32_t pdca6          : 4;
        uint32_t reserved8      : 4;
        uint32_t pdca7          : 4;
        uint32_t reserved9      : 4;
        uint32_t pdca8          : 4;
        uint32_t reserved10     : 4;
        uint32_t pdca9          : 4;
        uint32_t reserved11     : 4;
        uint32_t pdca10         : 4;
        uint32_t reserved12     : 4;
        uint32_t pdca11         : 4;
        uint32_t reserved13     : 4;
        uint32_t pdca12         : 4;
        uint32_t reserved14     : 4;
        uint32_t pdca13         : 4;
        uint32_t reserved15     : 4;
        uint32_t pdca14         : 4;
        uint32_t reserved16     : 4;
        uint32_t pdca15         : 4;
        uint32_t reserved17     : 4;
        uint32_t crccu          : 4;
        uint32_t reserved18     : 4;
        uint32_t usbc           : 4;
        uint32_t reserved19     : 4;
        uint32_t pevctr         : 4;
        uint32_t reserved20     : 4;
        uint32_t pevcov         : 4;
        uint32_t reserved21     : 4;
        uint32_t aesa           : 4;
        uint32_t reserved22     : 4;
        uint32_t pm             : 4;
        uint32_t reserved23     : 4;
        uint32_t scif           : 4;
        uint32_t reserved24     : 4;
        uint32_t freqm          : 4;
        uint32_t reserved25     : 4;
        uint32_t gpio0          : 4;
        uint32_t reserved26     : 4;
        uint32_t gpio1          : 4;
        uint32_t reserved27     : 4;
        uint32_t gpio2          : 4;
        uint32_t reserved28     : 4;
        uint32_t gpio3          : 4;
        uint32_t reserved29     : 4;
        uint32_t gpio4          : 4;
        uint32_t reserved30     : 4;
        uint32_t gpio5          : 4;
        uint32_t reserved31     : 4;
        uint32_t gpio6          : 4;
        //next word
        uint32_t reserved32     : 4;
        uint32_t gpio7          : 4;
        uint32_t reserved33     : 4;
        uint32_t gpio8          : 4;
        uint32_t reserved34     : 4;
        uint32_t gpio9          : 4;
        uint32_t reserved35     : 4;
        uint32_t gpio10         : 4;
        uint32_t reserved36     : 4;
        uint32_t gpio11         : 4;
        uint32_t reserved37     : 4;
        uint32_t bpm            : 4;
        uint32_t reserved38     : 4;
        uint32_t bscif          : 4;
        uint32_t reserved39     : 4;
        uint32_t ast_alarm      : 4;
        uint32_t reserved40     : 4;
        uint32_t ast_per        : 4;
        uint32_t reserved41     : 4;
        uint32_t ast_ovf        : 4;
        uint32_t reserved42     : 4;
        uint32_t ast_ready      : 4;
        uint32_t reserved43     : 4;
        uint32_t ast_clkready   : 4;
        uint32_t reserved44     : 4;
        uint32_t wdt            : 4;
        uint32_t reserved45     : 4;
        uint32_t eic1           : 4;
        uint32_t reserved46     : 4;
        uint32_t eic2           : 4;
        uint32_t reserved47     : 4;
        uint32_t eic3           : 4;
        uint32_t reserved48     : 4;
        uint32_t eic4           : 4;
        uint32_t reserved49     : 4;
        uint32_t eic5           : 4;
        uint32_t reserved50     : 4;
        uint32_t eic6           : 4;
        uint32_t reserved51     : 4;
        uint32_t eic7           : 4;
        uint32_t reserved52     : 4;
        uint32_t eic8           : 4;
        uint32_t reserved53     : 4;
        uint32_t iisc           : 4;
        uint32_t reserved54     : 4;
        uint32_t spi            : 4;
        uint32_t reserved55     : 4;
        uint32_t tc00           : 4;
        uint32_t reserved56     : 4;
        uint32_t tc01           : 4;
        uint32_t reserved57     : 4;
        uint32_t tc02           : 4;
        uint32_t reserved58     : 4;
        uint32_t tc10           : 4;
        uint32_t reserved59     : 4;
        uint32_t tc11           : 4;
        uint32_t reserved60     : 4;
        uint32_t tc12           : 4;
        uint32_t reserved61     : 4;
        uint32_t twim0          : 4;
        uint32_t reserved62     : 4;
        uint32_t twis0          : 4;
        uint32_t reserved63     : 4;
        uint32_t twim1          : 4;
        //next word
        uint32_t reserved64     : 4;
        uint32_t twis1          : 4;
        uint32_t reserved65     : 4;
        uint32_t usart0         : 4;
        uint32_t reserved66     : 4;
        uint32_t usart1         : 4;
        uint32_t reserved67     : 4;
        uint32_t usart2         : 4;
        uint32_t reserved68     : 4;
        uint32_t usart3         : 4;
        uint32_t reserved69     : 4;
        uint32_t adcife         : 4;
        uint32_t reserved70     : 4;
        uint32_t dacc           : 4;
        uint32_t reserved71     : 4;
        uint32_t acifc          : 4;
        uint32_t reserved72     : 4;
        uint32_t abdacb         : 4;
        uint32_t reserved73     : 4;
        uint32_t trng           : 4;
        uint32_t reserved74     : 4;
        uint32_t parc           : 4;
        uint32_t reserved75     : 4;
        uint32_t catb           : 4;
        uint32_t reserved76     : 12;
        uint32_t twim2          : 4;
        uint32_t reserved77     : 4;
        uint32_t twim3          : 4;
        uint32_t reserved78     : 4;
        uint32_t lcdca          : 4;
    } __attribute__((__packed__)) bits;
} nvic_pri_t;

//The arm core supports tons of interrupts, and the sam4l only supports 80. Therefore the nvix_x_t is only 12 bytes long.
//We need to pad by 5 words between fields to line up. In addition there is already a gap of 0x60 between fields
typedef struct
{
    //0x100
    nvic_x_t    iser;   //Set enable
    uint32_t    reserved0[5 + 24];
    //0x180
    nvic_x_t    icer;   //Clear enable
    uint32_t    reserved1[5 + 24];
    //0x200
    nvic_x_t    ispr;   //Set pending
    uint32_t    reserved2[5 + 24];
    //0x280
    nvic_x_t    icpr;   //clear pending
    uint32_t    reserved3[5 + 24];
    //0x300
nvic_x_t    iabr;       //active
    uint32_t    reserved4[5 + 24 + 32]; //Extra gap on this one
    //0x400
    nvic_pri_t  ipr;
} nvic_t;

nvic_t volatile * const NVIC = (nvic_t volatile *) 0xE000E100;

