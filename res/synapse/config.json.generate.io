cat << CTAG
{
	name:I/O控制,
		elements:[
			{ STitleBar:{
				title:"I/O控制"
			}},
				{ SSeekBar:{
					title:"预读取缓存大小",
					description:"设置内部存储器的预读取缓存大小。",
					unit:" KB",
					step:128,
					min:128,
					max:4096,
					default:`$BB cat /sys/block/mmcblk0/queue/read_ahead_kb`,
					action:"ioset queue read_ahead_kb"
				}},
				{ SOptionList:{
					title:"I/O 调度策略",
					description:"I/O 调度器决定了IO的读取时如何划分优先级的. 更多内容请参考: <a href='http://timos.me/tm/wiki/ioscheduler'>HERE</a>",
					default:`$BB echo $(/res/synapse/actions/bracket-option \`sh $DEVICE DirIOScheduler\`)`,
					action:"ioset scheduler",
					values:[
						`sh $DEVICE IOSchedulerList`
					],
					notify:[
						{
							on:APPLY,
							do:[ REFRESH, CANCEL ],
							to:"`sh $DEVICE DirIOSchedulerTree`"
						},
						{
							on:REFRESH,
							do:REFRESH,
							to:"`sh $DEVICE DirIOSchedulerTree`"
						}
					]
				}},
				`if [ -f "/sys/module/mmc_core/parameters/use_spi_crc" ]; then
				CRCS=\`bool /sys/module/mmc_core/parameters/use_spi_crc\`
					$BB echo '{ SPane:{
						title:"软件CRC控制"
					}},
						{ SCheckBox:{
							label:"数据冗余校验控制",
							description:"开启数据冗余校验控制会占用的 30% 以上的数据读写性能消耗。关闭可以获取更好的数据读写性能，但会使数据块的安全性不稳固，假如读写过程中出现意外可能会导致数据丢失，请谨慎选择。",
							default:'$CRCS',
							action:"boolean /sys/module/mmc_core/parameters/use_spi_crc"
						}},'
				fi`
				`if [ -f "/sys/devices/msm_sdcc.1/mmc_host/mmc0/clk_scaling/scale_down_in_low_wr_load" ]; then
				MMCC=\`$BB cat /sys/devices/msm_sdcc.1/mmc_host/mmc0/clk_scaling/scale_down_in_low_wr_load\`
				$BB echo '{ SPane:{
					title:"内置存储动态频率控制"
				}},
					{ SCheckBox:{
						label:"MMC频率控制",
						description:"在请求时优化MMC频率。默认为0，如果想提升性能，请选择1。",
						default:'$MMCC',
						action:"generic /sys/devices/msm_sdcc.1/mmc_host/mmc0/clk_scaling/scale_down_in_low_wr_load"
					}},'
				fi`
			{ SPane:{
				title:"通用读写策略",
				description:"设置内置储存的通用策略"
			}},
				{ SCheckBox:{
					description:"保护存储器的IO数据，禁用此选项将会导致IO监控软件故障.",
					label:"I/O Stats",
					default:`$BB cat /sys/block/mmcblk0/queue/iostats`,
					action:"ioset queue iostats"
				}},
				{ SOptionList:{
					title:"队列合并",
					description:"在存储器允许的情况下，按照调度器队列优先次序合并数据。大部分情况可以提升随即性能，但是某些情况下需要禁用。",
					default:`$BB cat /sys/block/mmcblk0/queue/nomerges`,
					action:"ioset queue nomerges",
					values:{
						0:"全部", 1:"部分", 2:"不合并"
					}
				}},
				{ SOptionList:{
					title:"队列亲和性",
					description:"尽量让IO请求放在同一CPU上，按照常理说IO队列申请队列的CPU作为处理请求的CPU可以提升性能。",
					default:`$BB cat /sys/block/mmcblk0/queue/rq_affinity`,
					action:"ioset queue rq_affinity",
					values:{
						0:"关闭", 1:"打开", 2:"更多合并"
					}
				}},
				{ SSeekBar:{
					title:"请求上限",
					description:"读或写入在队列中请求的最大数量。",
					step:128,
					min:128,
					max:2048,
					default:`$BB cat /sys/block/mmcblk0/queue/nr_requests`,
					action:"ioset queue nr_requests"
				}},
			{ SPane:{
				title:"I/O Scheduler Tunables"
			}},
				{ STreeDescriptor:{
					path:"`sh $DEVICE DirIOSchedulerTree`",
					generic: {
						directory: {},
						element: {
							SGeneric: { title:"@BASENAME" }
						}
					},
					exclude: [ "weights" ]
				}},
		]
}
CTAG
