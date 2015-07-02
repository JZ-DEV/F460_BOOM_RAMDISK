cat << CTAG
{
	name:I/O,
		elements:[
			{ STitleBar:{
				title:"I/O 控制"
			}},
				{ SSeekBar:{
					title:"预读取缓存大小",
					description:"设置内部存储器的预读取缓存大小.",
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
							label:"软件CRC校验",
							description:"使能软件CRC校验损失约30%的性能，所以我们允许被禁止",
							default:'$CRCS',
							action:"boolean /sys/module/mmc_core/parameters/use_spi_crc"
						}},'
				fi`
			{ SPane:{
				title:"通用IO微调选项",
				description:"设置内部存储器的IO微调选项"
			}},
				{ SCheckBox:{
					description:"Draw entropy from spinning (rotational) storage.",
					label:"Add Random",
					default:`$BB cat /sys/block/mmcblk0/queue/add_random`,
					action:"ioset queue add_random"
				}},
				{ SCheckBox:{
					description:"维护存储器的IO数据，禁用此选项将会导致IO监控软件故障.",
					label:"I/O Stats",
					default:`$BB cat /sys/block/mmcblk0/queue/iostats`,
					action:"ioset queue iostats"
				}},
				{ SCheckBox:{
					description:"Treat device as rotational storage.",
					label:"Rotational",
					default:`$BB cat /sys/block/mmcblk0/queue/rotational`,
					action:"ioset queue rotational"
				}},				
				{ SOptionList:{
					title:"无合并（No Merges）",
					description:"该存储设备所允许的调度队列的合并（优先级）类型.",
					default:`$BB cat /sys/block/mmcblk0/queue/nomerges`,
					action:"ioset queue nomerges",
					values:{
						0:"All", 1:"Simple Only", 2:"None"
					}
				}},
				{ SOptionList:{
					title:"RQ Affinity",
					description:"Try to have scheduler requests complete on the CPU core they were made from. Higher is more aggressive. Some kernels only support 0-1.",
					default:`$BB cat /sys/block/mmcblk0/queue/rq_affinity`,
					action:"ioset queue rq_affinity",
					values:{
						0:"Disabled", 1:"Enabled", 2:"Aggressive"
					}
				}},
				{ SSeekBar:{
					title:"NR Requests",
					description:"Maximum number of read (or write) requests that can be queued to the scheduler in the block layer.",
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
