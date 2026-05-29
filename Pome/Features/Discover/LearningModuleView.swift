import SwiftUI
import UIKit

enum LearningModule: String, Identifiable, CaseIterable {
    case primary
    case middle
    case high
    case gaokao

    var id: String { rawValue }

    var title: String {
        switch self {
        case .primary:
            return "小学必背诗文"
        case .middle:
            return "初中必背诗文"
        case .high:
            return "高中必背诗文"
        case .gaokao:
            return "高考诗文真题"
        }
    }

    var subtitle: String {
        switch self {
        case .primary:
            return "义务课标 1-6 年级推荐篇目"
        case .middle:
            return "义务课标 7-9 年级推荐篇目"
        case .high:
            return "普高课标推荐篇目"
        case .gaokao:
            return "名篇名句补写真题训练"
        }
    }

    var icon: String {
        switch self {
        case .primary:
            return "sun.max.fill"
        case .middle:
            return "book.closed.fill"
        case .high:
            return "graduationcap.fill"
        case .gaokao:
            return "doc.text.magnifyingglass"
        }
    }

    var accentColor: Color {
        switch self {
        case .primary:
            return Color(red: 0.93, green: 0.48, blue: 0.32)
        case .middle:
            return AppTheme.primaryColor
        case .high:
            return Color(red: 0.18, green: 0.55, blue: 0.46)
        case .gaokao:
            return AppTheme.secondaryColor
        }
    }

    var gradeName: String? {
        switch self {
        case .primary:
            return "小学"
        case .middle:
            return "初中"
        case .high:
            return "高中"
        case .gaokao:
            return nil
        }
    }

    var itemCount: Int {
        switch self {
        case .primary:
            return LearningPoemCatalog.primaryCount
        case .middle:
            return LearningPoemCatalog.middleSchoolCount
        case .high:
            return LearningPoemCatalog.highSchoolCount
        case .gaokao:
            return GaokaoPoetryQuestion.sampleQuestionCount
        }
    }

    var itemUnit: String {
        switch self {
        case .primary, .middle, .high:
            return "篇"
        case .gaokao:
            return "套真题"
        }
    }
}

struct LearningModuleSection: View {
    let onSelect: (LearningModule) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing_md) {
            Text("学习模块")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
                .padding(.horizontal, AppTheme.spacing_lg)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: AppTheme.spacing_md),
                    GridItem(.flexible(), spacing: AppTheme.spacing_md)
                ],
                spacing: AppTheme.spacing_md
            ) {
                ForEach(LearningModule.allCases) { module in
                    Button(action: {
                        onSelect(module)
                    }) {
                        LearningModuleCard(
                            module: module,
                            countText: countText(for: module)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, AppTheme.spacing_lg)
        }
    }

    private func countText(for module: LearningModule) -> String {
        "\(module.itemCount) \(module.itemUnit)"
    }
}

private struct LearningModuleCard: View {
    let module: LearningModule
    let countText: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing_sm) {
            HStack {
                Image(systemName: module.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(module.accentColor)
                    .cornerRadius(AppTheme.cornerRadius_sm)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppTheme.textSecondary)
            }

            Text(module.title)
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            Text(module.subtitle)
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            Text(countText)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(module.accentColor)
                .padding(.top, AppTheme.spacing_xs)
        }
        .frame(maxWidth: .infinity, minHeight: 142, alignment: .topLeading)
        .padding(AppTheme.spacing_md)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadius_md)
        .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 2)
    }
}

struct LearningModuleDetailView: View {
    let module: LearningModule

    var body: some View {
        if module == .gaokao {
            GaokaoLearningModuleDetailView(module: module)
        } else {
            PoemLearningModuleDetailView(module: module)
        }
    }
}

private struct PoemLearningModuleDetailView: View {
    let module: LearningModule
    @State private var navigationController: UINavigationController?

    private var poems: [Poem] {
        guard module.gradeName != nil else {
            return []
        }

        return LearningPoemCatalog.poems(for: module)
    }

    var body: some View {
        Group {
            if poems.isEmpty {
                LearningEmptyState(module: module)
            } else {
                List {
                    Section {
                        LearningModuleSummary(module: module, poemCount: poems.count)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)

                    Section("篇目") {
                        ForEach(poems) { poem in
                            Button(action: {
                                pushPoem(poem)
                            }) {
                                PoemLearningRow(poem: poem)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .background(AppTheme.backgroundColor)
            }
        }
        .navigationTitle(module.title)
        .navigationBarTitleDisplayMode(.inline)
        .background(
            NavigationControllerReader { navigationController in
                self.navigationController = navigationController
            }
        )
    }

    private func pushPoem(_ poem: Poem) {
        let hostingController = UIHostingController(rootView: LazyResolvedPoemDetailView(seedPoem: poem))
        hostingController.title = poem.title
        hostingController.hidesBottomBarWhenPushed = true
        (navigationController ?? LearningNavigationResolver.findNavigationController())?.pushViewController(hostingController, animated: true)
    }
}

private struct LazyResolvedPoemDetailView: View {
    let seedPoem: Poem
    @ObservedObject private var poemService = PoemService.shared

    private var poem: Poem {
        let resolvedPoem = LearningPoemCatalog.resolvedPoem(seedPoem, from: poemService.poems)
        return LearningPoemSupplement.enriched(resolvedPoem, fallbackSeed: seedPoem)
    }

    var body: some View {
        PoemDetailView(poem: poem)
    }
}

private struct LearningPoemSupplement {
    let remark: String?
    let translation: String?
    let shangxi: String?

    static func enriched(_ poem: Poem, fallbackSeed seed: Poem) -> Poem {
        guard let supplement = supplement(for: seed) ?? supplement(for: poem) else {
            return poem
        }

        return Poem(
            title: poem.title,
            dynasty: poem.dynasty,
            writer: poem.writer,
            content: poem.content,
            remark: preferred(poem.remark, supplement.remark),
            translation: preferred(poem.translation, supplement.translation),
            shangxi: preferred(poem.shangxi, supplement.shangxi),
            tags: poem.tags ?? seed.tags
        )
    }

    private static func preferred(_ current: String?, _ fallback: String?) -> String? {
        guard let current = current, !current.isEmpty else {
            return fallback
        }

        return current
    }

    private static func supplement(for poem: Poem) -> LearningPoemSupplement? {
        let exactKey = key(poem.title, poem.writer, firstLine(of: poem.content))
        let titleKey = key(poem.title, poem.writer, nil)
        return supplements[exactKey] ?? supplements[titleKey]
    }

    private static let supplements: [String: LearningPoemSupplement] = Dictionary(uniqueKeysWithValues: [
        item("江南", "汉乐府", nil, remark: "田田：荷叶茂盛的样子。", translation: "江南可以采莲，莲叶一片片多么茂盛，鱼儿在莲叶间自在游动。", shangxi: "全诗以反复句式写采莲水乡的明快景象，语言朴素，节奏轻快。"),
        item("长歌行", "汉乐府", nil, remark: "晞：晒干。焜黄：草木枯黄。", translation: "园中葵菜在晨露中等待阳光，万物因春天恩泽而生长；百川东流不回，少年若不努力，年老只能徒然悲伤。", shangxi: "诗歌借自然盛衰和江河东流说明时光不可追回，劝人珍惜青春、及时奋发。"),
        item("敕勒歌", "北朝民歌", nil, remark: "穹庐：游牧民族居住的圆顶毡帐。见：同“现”。", translation: "敕勒川在阴山脚下，天空像巨大的毡帐笼罩四野；天色苍茫，原野辽阔，风吹草低显出成群牛羊。", shangxi: "这首民歌用开阔的空间和动态画面表现北方草原的雄浑壮美。"),
        item("咏鹅", "骆宾王", nil, remark: "曲项：弯着脖子。拨：划动。", translation: "鹅儿弯着脖子向天歌唱，洁白羽毛浮在绿水上，红色脚掌划动清波。", shangxi: "诗中颜色鲜明、动作生动，展现儿童观察自然的天真趣味。"),
        item("风", "李峤", nil, remark: "三秋：晚秋。斜：倾斜。", translation: "风能吹落晚秋树叶，催开二月鲜花；过江时掀起大浪，吹入竹林使万竿倾斜。", shangxi: "全诗不直接写风形，而通过叶、花、浪、竹表现风的力量。"),
        item("咏柳", "贺知章", nil, remark: "碧玉：青绿色美玉，这里比喻柳树。丝绦：丝带。", translation: "高高柳树像碧玉装点而成，万条柳枝垂下如绿色丝带；不知是谁裁出细叶，原来是二月春风像剪刀。", shangxi: "诗歌用比喻和拟人写早春新柳，想象新奇，语调轻快。"),
        item("回乡偶书", "贺知章", nil, remark: "鬓毛衰：鬓发稀疏花白。", translation: "少年离家，年老才回，乡音未改而鬓发已衰；儿童见了不认识，笑问客人从哪里来。", shangxi: "诗中以儿童一问写出久别还乡的感慨，平淡中含深情。"),
        item("凉州词", "王之涣", nil, remark: "仞：古代长度单位。玉门关：古代边关名。", translation: "黄河仿佛从白云间远来，孤城矗立在万仞高山之间；羌笛不必埋怨杨柳，春风本就吹不到玉门关。", shangxi: "诗歌写边塞辽远荒寒，既有壮阔景象，也含征人思乡之情。"),
        item("登鹳雀楼", "王之涣", nil, remark: "穷：尽。更：再。", translation: "夕阳依山落下，黄河奔流入海；想看得更远，就要再登上一层楼。", shangxi: "前两句写壮阔景象，后两句蕴含积极进取、登高望远的哲理。"),
        item("春晓", "孟浩然", nil, remark: "晓：天亮。闻：听见。", translation: "春夜酣睡不觉天亮，到处听见鸟鸣；昨夜风雨不断，不知花落了多少。", shangxi: "诗从晨起听觉写春意，又由风雨想到落花，含蓄表现惜春之情。"),
        item("凉州词", "王翰", nil, remark: "夜光杯：美玉制成的酒杯。催：催促。", translation: "葡萄美酒斟满夜光杯，正要痛饮时琵琶声在马上催促；醉卧沙场也请不要笑，自古出征有几人能平安回来？", shangxi: "诗以豪饮写边塞征战，豪放语气中暗含战争残酷。"),
        item("出塞", "王昌龄", nil, remark: "龙城飞将：指英勇善战的将领。胡马：敌方骑兵。", translation: "秦汉时的明月和边关依旧，远征万里的士兵尚未归来；只要有飞将军那样的名将在，就不会让敌骑越过阴山。", shangxi: "诗歌借古关明月写边患绵延，表达渴望良将守边、保家卫国的愿望。"),
        item("芙蓉楼送辛渐", "王昌龄", nil, remark: "平明：天刚亮。冰心：纯洁之心。", translation: "寒雨连江，夜入吴地，清晨送别友人，只见楚山孤立；若洛阳亲友问起我，就说我的心像玉壶中的冰一样清白。", shangxi: "诗中送别之情与自明心迹结合，孤清而高洁。"),
        item("鹿柴", "王维", nil, remark: "返景：夕阳返照的光。", translation: "空山中看不见人，只听到人声回响；夕阳照入深林，又映在青苔上。", shangxi: "诗以声衬静、以光写幽，体现王维山水诗空灵清寂的特点。"),
        item("送元二使安西", "王维", nil, remark: "浥：润湿。阳关：古代通往西域的重要关口。", translation: "渭城清晨细雨润湿轻尘，客舍旁柳色青青；请再饮一杯酒，出了阳关就难遇故人了。", shangxi: "诗用春雨柳色衬托离别，末句直抒深情，成为送别名句。"),
        item("九月九日忆山东兄弟", "王维", nil, remark: "山东：华山以东，指诗人家乡。茱萸：重阳节佩戴的香草。", translation: "独在异乡做客，每逢佳节更加思念亲人；想到兄弟们登高佩茱萸，只少了我一人。", shangxi: "诗从自身孤独写到家人活动，情感朴素真切。"),
        item("静夜思", "李白", nil, remark: "疑：好像。举头：抬头。", translation: "床前洒满明亮月光，好像地上结了白霜；抬头望见明月，低头思念故乡。", shangxi: "全诗语言浅近，以月光引出乡思，情感自然深沉。"),
        item("望庐山瀑布", "李白", nil, remark: "香炉：庐山香炉峰。紫烟：紫色烟霞。", translation: "阳光照着香炉峰升起紫烟，远望瀑布像白练挂在山前；飞流直下仿佛三千尺，好像银河从九天落下。", shangxi: "诗用夸张和想象写瀑布气势，呈现李白诗歌的浪漫豪放。"),
        item("赠汪伦", "李白", nil, remark: "踏歌：一边唱歌一边用脚踏地打拍子。", translation: "李白正要乘船离去，忽然听见岸上传来踏歌声；桃花潭水即使深千尺，也比不上汪伦送我的情谊。", shangxi: "诗用潭水之深衬友情之深，明白如话而情意真挚。"),
        item("黄鹤楼送孟浩然之广陵", "李白", nil, remark: "广陵：今江苏扬州。碧空尽：消失在蓝天尽头。", translation: "老朋友从黄鹤楼辞别，在烟花三月下扬州；孤帆渐远消失在碧空尽头，只见长江流向天边。", shangxi: "诗不直说离愁，而以远帆和长江写目送之情，意境开阔。"),
        item("早发白帝城", "李白", nil, remark: "朝辞：早晨辞别。还：返回。", translation: "清晨辞别彩云间的白帝城，千里江陵一日可还；两岸猿声还未停息，轻舟已越过万重青山。", shangxi: "诗写行船迅疾，表现诗人轻快畅达的心情。"),
        item("望天门山", "李白", nil, remark: "中断：从中间断开。楚江：长江流经楚地的一段。", translation: "天门山被江水从中冲开，碧绿江水东流到这里回旋；两岸青山相对而出，一片孤帆从日边驶来。", shangxi: "诗以动态笔法写山水相映，画面开阔明丽。"),
        item("别董大", "高适", nil, remark: "曛：昏暗。知己：了解赏识自己的人。", translation: "千里黄云遮天，北风吹雁、大雪纷飞；不要担心前路没有知己，天下谁不认识你呢？", shangxi: "诗在苍茫景象中表达豪迈劝慰，送别而不伤感。"),
        item("绝句", "杜甫", "两个黄鹂鸣翠柳，一行白鹭上青天。", remark: "泊：停靠。东吴：古代地区名。", translation: "两只黄鹂在翠柳间鸣叫，一行白鹭飞上青天；窗口含着西岭千年积雪，门前停泊着来自东吴的船。", shangxi: "诗中黄、翠、白、青色彩鲜明，远近结合，呈现清新开阔的春景。"),
        item("绝句", "杜甫", "迟日江山丽，春风花草香。", remark: "迟日：春日。泥融：泥土湿软。", translation: "春日里江山秀丽，春风送来花草香气；泥土湿软，燕子飞来筑巢，沙地温暖，鸳鸯安睡。", shangxi: "诗以视觉、嗅觉和动物动态写春天生机，语言明快。"),
        item("春夜喜雨", "杜甫", nil, remark: "乃：就。潜：悄悄地。", translation: "好雨知道时节，正当春天万物生长时降临；它随风潜入夜里，细细滋润万物而无声。", shangxi: "诗人把春雨写得善解人意，表达对及时雨和民生丰收的喜悦。"),
        item("枫桥夜泊", "张继", nil, remark: "泊：停船靠岸。姑苏：今苏州。", translation: "月落乌啼，霜气满天，江枫渔火对着愁眠；姑苏城外寒山寺，半夜钟声传到客船。", shangxi: "诗用秋夜景物和钟声烘托旅人孤寂愁绪，意境清冷悠远。"),
        item("游子吟", "孟郊", nil, remark: "寸草心：小草般微弱的心意。三春晖：春天阳光，比喻母爱。", translation: "慈母手中拿着针线，为远行的孩子缝衣；谁说小草般的孝心，能报答春晖般的母爱？", shangxi: "诗以临行缝衣的细节表现母爱深厚，质朴动人。"),
        item("赋得古原草送别", "白居易", nil, remark: "离离：草木繁盛的样子。萋萋：草木茂盛。", translation: "古原上的草一年一枯一荣，野火烧不尽，春风一吹又生；远芳蔓延古道，晴翠连着荒城，又送友人离去，满目青草都是别情。", shangxi: "诗借野草顽强生命力和绵延春色写送别，情景交融。"),
        item("悯农", "李绅", "锄禾日当午，汗滴禾下土。", remark: "当午：正午。皆：都。", translation: "农民正午在田里锄草，汗水滴落到禾苗下的泥土；谁知道盘中饭食，每一粒都来之不易。", shangxi: "诗用劳动场景提醒人们珍惜粮食，体恤农民辛苦。"),
        item("悯农", "李绅", "春种一粒粟，秋收万颗子。", remark: "粟：谷子。犹：仍然。", translation: "春天种下一粒谷种，秋天收获万颗粮食；四海没有荒闲田地，农民却仍可能挨饿。", shangxi: "诗揭示劳动者辛苦生产却生活困苦的现实，含有强烈同情。"),
        item("江雪", "柳宗元", nil, remark: "绝：没有。蓑笠翁：披蓑衣戴斗笠的老渔翁。", translation: "群山中飞鸟绝迹，所有道路不见人踪；孤舟上披蓑戴笠的老翁，独自在寒江雪中垂钓。", shangxi: "诗以极静极寒的画面写孤高坚守，也寄寓诗人的孤独心境。"),
        item("山行", "杜牧", nil, remark: "坐：因为。霜叶：经霜变红的枫叶。", translation: "沿着弯曲石径上寒山，白云深处有人家；因喜爱傍晚枫林而停车，霜叶比二月花还红。", shangxi: "诗把秋景写得明丽热烈，体现诗人对自然美的喜爱。"),
        item("清明", "杜牧", nil, remark: "断魂：形容悲伤失意。遥指：远远指着。", translation: "清明时节细雨纷纷，路上行人神情黯然；问哪里有酒家，牧童远远指向杏花村。", shangxi: "诗以雨中问路的小场景写清明旅愁，画面鲜活。"),
        item("江南春", "杜牧", nil, remark: "山郭：山城。酒旗：酒家的旗帜。", translation: "千里江南莺啼绿树红花相映，水村山城酒旗飘动；南朝留下众多寺庙楼台，多少都在烟雨之中。", shangxi: "诗把江南春景和历史兴亡感交织，明丽中含淡淡感慨。"),
        item("元日", "王安石", nil, remark: "屠苏：古代春节饮用的酒。曈曈：太阳初升明亮的样子。", translation: "爆竹声中旧岁过去，春风送暖，人们饮屠苏酒；千家万户迎着初升太阳，总把旧桃符换成新的。", shangxi: "诗写春节新气象，也暗含除旧布新的政治理想。"),
        item("泊船瓜洲", "王安石", nil, remark: "京口、瓜洲、钟山：地名。绿：使动用法，使江南岸变绿。", translation: "京口和瓜洲只隔一条江，钟山也只隔几重山；春风又吹绿江南岸，明月何时照我回家？", shangxi: "诗以春色触发思乡之情，炼字精妙，情味悠长。"),
        item("题西林壁", "苏轼", nil, remark: "缘：因为。", translation: "从正面、侧面看庐山形态不同，远近高低也各不相同；认不清庐山真面目，只因自己身在山中。", shangxi: "诗由游山悟理，说明观察事物要跳出局限、全面认识。"),
        item("小池", "杨万里", nil, remark: "惜：爱惜。尖尖角：初露水面的荷叶尖。", translation: "泉眼无声，好像舍不得细流；树荫映水，喜爱晴日柔光；小荷刚露尖角，已有蜻蜓停在上头。", shangxi: "诗捕捉初夏小景，细腻清新，富有生活情趣。"),
        item("晓出净慈寺送林子方", "杨万里", nil, remark: "毕竟：到底。别样红：格外鲜红。", translation: "到底是六月西湖，风光和四时不同；莲叶接天无边碧绿，荷花映日格外鲜红。", shangxi: "诗用强烈色彩写西湖荷景，境界开阔明艳。"),
        item("春日", "朱熹", nil, remark: "胜日：晴好的日子。等闲：轻易、随便。", translation: "晴日到泗水边寻春，无边风光焕然一新；轻易认出东风面貌，万紫千红总是春天。", shangxi: "表面写游春，实含追求学问与生命更新的意味。"),
        item("石灰吟", "于谦", nil, remark: "若等闲：好像平常事。清白：洁白，也指高洁操守。", translation: "石灰经千锤万凿出深山，把烈火焚烧看作平常；即使粉身碎骨也不怕，只愿把清白留在人间。", shangxi: "诗托物言志，借石灰表现坚贞不屈、清白自守的人格。"),
        item("竹石", "郑燮", nil, remark: "坚劲：坚韧挺拔。任尔：任凭你。", translation: "竹子紧咬青山不放，根扎在破裂岩石中；经历千磨万击仍坚韧，任凭东西南北风吹打。", shangxi: "诗借竹石表现坚韧不拔、刚正不屈的精神。"),
        item("村居", "高鼎", nil, remark: "拂堤：轻拂堤岸。纸鸢：风筝。", translation: "二月草长莺飞，杨柳轻拂堤岸，春烟迷人；儿童放学早，忙趁东风放风筝。", shangxi: "诗以儿童活动点染春景，画面明快，充满生机。"),
        item("陋室铭", "刘禹锡", nil, remark: "铭：古代刻在器物上用以警戒自己或称述功德的文字。馨：香气，这里指品德高尚。鸿儒：博学的人。白丁：平民，这里指没有功名的人。", translation: "山不一定要高，有仙人就会出名；水不一定要深，有龙就显得灵异。这是简陋的屋子，只因我的品德高尚而不觉简陋。苔痕碧绿长到台阶上，草色青葱映入帘中。谈笑往来的是博学之人，没有浅薄无学之辈。可以弹奏素琴、阅读佛经；没有世俗音乐扰乱耳朵，也没有官府公文劳累身心。它好比南阳诸葛亮的草庐、西蜀扬雄的亭子。孔子说：有什么简陋呢？", shangxi: "文章借陋室不陋表现作者安贫乐道、洁身自好的志趣。全文骈散结合，语言精练，托物言志，结尾引用孔子之语收束有力。"),
        item("爱莲说", "周敦颐", nil, remark: "蕃：多。濯：洗。清涟：清水。亵玩：亲近而不庄重地玩赏。鲜：少。", translation: "水上、陆地上草木的花，值得喜爱的很多。晋代陶渊明只喜爱菊花，唐代以来世人很喜爱牡丹。我唯独喜爱莲从淤泥里长出却不被污染，经过清水洗涤却不显妖艳；它中间贯通、外形挺直，不横生枝蔓，不旁生枝节，香气越远越清，洁净地挺立在那里，只能远远观赏而不能轻慢玩弄。", shangxi: "文章以莲喻君子，托物言志。作者借菊、牡丹作陪衬，突出莲洁身自好、正直端庄的品格，也表达自己不慕富贵的操守。"),
        item("三峡", "郦道元", nil, remark: "略无：完全没有。阙：同“缺”，空隙。襄陵：漫上山陵。沿溯：顺流而下和逆流而上。属引：连续不断。", translation: "在三峡七百里之间，两岸群山相连，几乎没有中断。夏天江水上涨，行船常被阻断；有急令传达时，早晨从白帝城出发，傍晚就能到江陵，即使骑着快马、驾着疾风也没有这样快。春冬时节，白色急流和碧绿深潭相映，倒影清丽；秋天晴朗或降霜的早晨，树林山涧清寒肃杀，猿声凄厉，久久回响。", shangxi: "文章以凝练笔墨写三峡四时景象，先写山势雄奇，再写夏水迅疾、春冬清丽、秋景凄清，动静结合，层次鲜明。"),
        item("记承天寺夜游", "苏轼", nil, remark: "户：门。念：想到。相与：共同、一起。盖：大概是。闲人：清闲的人，也含被贬后自嘲之意。", translation: "元丰六年十月十二日夜里，我脱衣准备睡觉，看见月光照进门里，便高兴地起身出门。想到没有人可以一起游乐，就到承天寺寻找张怀民。张怀民也没有睡，我们一起在庭院中散步。庭院里的月光像积水一样清澈透明，水中仿佛有水草交错，原来是竹子和柏树的影子。哪一夜没有月光？哪里没有竹柏？只是少有像我们这样的闲人罢了。", shangxi: "短文以夜游小事写出空明月色和旷达心境。景物描写极简而传神，“闲人”一语兼有自嘲、自慰与超脱。"),
        item("岳阳楼记", "范仲淹", nil, remark: "谪守：被贬为太守。具：同“俱”，全、都。属：同“嘱”，嘱托。浩浩汤汤：水势浩大的样子。微：如果没有。", translation: "庆历四年春，滕子京被贬任巴陵郡太守。第二年，政事顺利，百姓和乐，许多荒废事业都兴办起来。他重修岳阳楼，并嘱托我写文章记述。洞庭湖衔接远山、吞吐长江，气象万千。面对阴晴变化，迁客骚人的情感往往不同。古代仁人却不因外物和自身得失而或喜或悲，在朝廷就忧虑百姓，身处江湖就忧虑君主，先于天下人忧虑，后于天下人享乐。", shangxi: "文章由楼景写到迁客情怀，进而提出“不以物喜，不以己悲”的胸襟和“先忧后乐”的政治理想，结构开阔，议论深沉。"),
        item("醉翁亭记", "欧阳修", nil, remark: "蔚然：茂盛的样子。翼然：像鸟张开翅膀一样。辄：就。意：情趣。寓：寄托。", translation: "滁州四面都是山，西南诸峰树林山谷尤其秀美，其中远望树木茂盛、幽深秀丽的是琅琊山。沿山走六七里，听见水声潺潺，那是酿泉。山势回环，道路转折，有一座亭子像鸟展开翅膀一样临近泉边，这就是醉翁亭。太守和宾客来这里饮酒，喝得不多就醉，又年纪最大，所以自号醉翁。醉翁的情趣不在酒，而在山水之间。", shangxi: "文章以“乐”为线索，把山水之乐、宴饮之乐、游人之乐与太守之乐融为一体，语言骈散结合，节奏舒缓自然。"),
        item("出师表", "诸葛亮", nil, remark: "崩殂：帝王去世。秋：时候。开张圣听：扩大圣明的听闻。菲薄：轻视。卑鄙：身份低微、见识浅陋。驱驰：奔走效劳。", translation: "先帝创业还没有完成一半就中途去世，如今天下分裂，益州疲弱，这实在是危急存亡的时候。侍卫大臣在朝中不懈怠，忠诚将士在外舍身忘死，是因为追念先帝的特殊礼遇，想报答陛下。陛下应广泛听取意见，发扬先帝遗德，振奋志士气概，不应妄自菲薄、说话失当，堵塞忠臣进谏的道路。", shangxi: "文章情辞恳切，既陈述国家形势，又劝勉后主亲贤远佞，表现诸葛亮忠贞报国、谨慎担当的臣子情怀。"),
        item("桃花源记", "陶渊明", nil, remark: "缘：沿着。鲜美：新鲜美好。落英：落花。俨然：整齐的样子。阡陌：田间小路。黄发垂髫：老人和小孩。", translation: "武陵有个渔人沿溪而行，忘了路的远近，忽然遇见一片桃花林。林中芳草鲜美，落花繁多。渔人继续前行，穿过山口后眼前开阔，只见土地平坦宽广，房屋整齐，有良田、美池和桑竹。田间小路交错相通，鸡犬之声彼此可闻，人们来往耕作，老人和孩子都安适快乐。", shangxi: "文章虚构桃花源这一理想世界，寄托作者对和平安宁生活的向往，也含有对现实动乱和压迫的不满。叙事层层推进，富有画面感。"),
        item("小石潭记", "柳宗元", nil, remark: "篁竹：竹林。珮环：玉佩、玉环。清冽：清凉。佁然：静止不动的样子。悄怆：忧伤。幽邃：幽深。", translation: "从小丘向西走一百二十步，隔着竹林听见水声，好像玉佩玉环相碰，我心里很高兴。砍开竹子开出道路，向下看见小潭，潭水格外清凉。潭中约有一百来条鱼，都像在空中游动，没有依靠。阳光照到水底，鱼影映在石上。向潭西南望去，溪流像北斗星那样曲折，像蛇那样蜿蜒。坐在潭边，四周竹树环合，幽静凄清，不宜久留。", shangxi: "文章以发现小潭、观鱼、望溪、感受环境为顺序，写景清丽而含幽怨，表现柳宗元被贬后孤寂压抑的心境。"),
        item("湖心亭看雪", "张岱", nil, remark: "更定：初更以后。拏：撑船。毳衣：细毛皮衣。雾凇沆砀：冰花一片弥漫。白：古人罚酒用的酒杯。客此：客居此地。", translation: "崇祯五年十二月，我住在西湖。大雪下了三天，湖中人声鸟声都消失了。这天初更以后，我撑一只小船，穿着毛皮衣、带着炉火，独自前往湖心亭看雪。湖上冰花弥漫，天、云、山、水上下全白，湖上的影子只剩长堤一道痕、湖心亭一点、我的小舟一叶和舟中两三个人影。到亭上遇见两人对坐饮酒，他们惊喜地说湖中竟还有这样的人。", shangxi: "文章以白描写雪后西湖，景象空阔清寒。作者夜访湖心亭的“痴”表现出遗世独立的审美情趣，也流露出故国之思。"),
        item("司马光", "佚名", nil, remark: "庭：庭院。瓮：口小腹大的陶器。皆：全、都。迸：涌出。", translation: "一群孩子在庭院里玩，一个孩子爬上水缸，失足掉进水里。大家都跑开了，司马光拿石头砸破水缸，水涌出来，孩子得救了。", shangxi: "短文通过危急时刻的举动表现司马光沉着机智，语言简洁，情节清楚。"),
        item("守株待兔", "韩非", nil, remark: "株：树桩。走：跑。释：放下。耒：古代农具。冀：希望。", translation: "宋国有个耕田的人，田里有个树桩。一只兔子跑来撞在树桩上，折断脖子死了。于是他放下农具守着树桩，希望再得到兔子。兔子不能再得到，他自己却被宋国人嘲笑。", shangxi: "寓言讽刺把偶然当必然、不愿劳动只想侥幸的人，故事短小却寓意清楚。"),
        item("精卫填海", "山海经", nil, remark: "少女：小女儿。溺：淹没。故：因此。堙：填塞。", translation: "炎帝的小女儿名叫女娃。女娃到东海游玩，溺水没有回来，因此化为精卫鸟。她常常衔着西山的树枝和石块，用来填塞东海。", shangxi: "神话以精卫不息填海表现坚韧执着、不屈抗争的精神。"),
        item("王戎不取道旁李", "刘义庆", nil, remark: "尝：曾经。竞走：争着跑过去。唯：只有。信然：确实如此。", translation: "王戎七岁时，曾和孩子们一起玩。看见路边李树果实多得压弯树枝，孩子们争着跑去摘，只有王戎不动。别人问他，他说：树在路边却有这么多果子，这一定是苦李。摘来一尝，果然如此。", shangxi: "故事通过“不取李”的细节表现王戎善于观察、善于推理。"),
        item("囊萤夜读", "晋书", nil, remark: "恭勤：谨慎勤勉。练囊：白色绢袋。盛：装。以夜继日：夜以继日。", translation: "车胤勤勉不倦，博学通达。家里贫穷，不能常有灯油，夏夜就用白绢袋装几十只萤火虫照着书本，夜以继日地读书。", shangxi: "文章突出勤学苦读的精神，用萤火照书的细节很有画面感。"),
        item("铁杵成针", "祝穆", nil, remark: "未成：没有完成学业。弃去：放弃离开。老媪：老妇人。卒业：完成学业。", translation: "传说李白在山中读书，没有完成学业就放弃离开。经过溪边时，遇见老妇人正在磨铁棒。李白问她做什么，她说想磨成针。李白被她的意志感动，回去完成学业。", shangxi: "故事以“铁杵磨针”说明只要有恒心，长期努力就能成功。"),
        item("少年中国说 节选", "梁启超", nil, remark: "故：所以。伏流：地下流动的水。潜龙：潜藏的龙。乳虎：幼虎。", translation: "今天的责任不在别人，全在我们少年。少年聪明，国家就聪明；少年强大，国家就强大；少年进步，国家就进步。红日刚刚升起，道路充满光明；黄河潜流奔出，一泻千里；潜龙腾起深渊，幼虎在山谷中啸叫。", shangxi: "文章以排比和比喻激励少年奋发向上，气势昂扬，充满强烈的时代责任感。"),
        item("学弈", "孟子", nil, remark: "弈：下棋。通国：全国。诲：教导。鸿鹄：天鹅。缴：系在箭上的丝绳。", translation: "弈秋是全国善于下棋的人。让他教两个人下棋，其中一个专心致志，只听弈秋的教导；另一个虽然也在听，却一心想着有天鹅要飞来，想拿弓箭去射。虽然一起学习，后一个不如前一个。是因为他的智力不如别人吗？回答说：不是这样。", shangxi: "短文通过两人学棋的对比，说明学习必须专心致志。"),
        item("两小儿辩日", "列子", nil, remark: "辩斗：争辩。去：距离。盘盂：盛物的器皿。探汤：把手伸进热水里。孰：谁。汝：你。知：同“智”。", translation: "孔子向东游学，见两个孩子争辩太阳远近。一个认为太阳刚出来时离人近，中午远；另一个认为刚出来远，中午近。前者以太阳早晨大、中午小为证，后者以早晨凉、中午热为证。孔子不能判定。两个孩子笑着说：谁说你智慧多呢？", shangxi: "故事表现孩子敢于质疑、善于观察，也说明认识事物需要多角度思考。"),
        item("伯牙鼓琴", "吕氏春秋", nil, remark: "鼓琴：弹琴。志：心意。太山：泰山。少选：一会儿。汤汤：水势浩大的样子。绝弦：割断琴弦。", translation: "伯牙弹琴，锺子期听。伯牙心里想着泰山，锺子期说琴声像巍峨的泰山；过了一会儿，伯牙心里想着流水，锺子期又说琴声像浩荡的流水。锺子期死后，伯牙摔破琴、割断弦，终身不再弹琴，认为世上再没有值得为他弹琴的人。", shangxi: "故事表现知音难得和真挚友情，“高山流水”也成为知音相赏的典故。"),
        item("书戴嵩画牛", "苏轼", nil, remark: "好：喜爱。所宝：所珍藏的东西。曝：晒。拊掌：拍手。搐：收缩。然之：认为他说得对。", translation: "蜀地有个杜处士喜爱书画，珍藏很多。其中一幅戴嵩画的牛，他尤其喜爱。一天晒书画，有个牧童看见后拍手大笑，说画的是斗牛，牛相斗时力气在角上，尾巴会夹在两腿之间，而画上却摇着尾巴斗，错了。杜处士笑着认为他说得对。", shangxi: "文章借牧童指出名画错误，说明实践经验的重要，也表现苏轼重视求真精神。"),
        item("杨氏之子", "刘义庆", nil, remark: "惠：同“慧”，聪明。诣：拜访。乃：于是。示：给……看。夫子：对男子的敬称。家禽：家中的鸟。", translation: "梁国杨家的孩子九岁，非常聪明。孔君平拜访他的父亲，父亲不在，就叫孩子出来。孩子为他摆上水果，水果里有杨梅。孔君平指着杨梅给孩子看，说这是你家的果子。孩子马上回答：没听说孔雀是先生家的鸟。", shangxi: "短文以机智应答表现孩子语言敏捷，回答既贴合姓氏又有礼貌。"),
        item("劝学", "荀子", nil, remark: "已：停止。中绳：合乎墨线。輮：同“煣”，用火烤使木弯曲。参省：检查反省。跬步：半步。驽马：劣马。", translation: "君子说：学习不可以停止。青色从蓝草中取得，却比蓝草更青；冰由水凝成，却比水更冷。木材经墨线量过就能取直，金属靠磨刀石就能锋利。君子广泛学习并每天反省自己，就会智慧明达、行为少过。积累土石成山，风雨就会兴起；不积累半步，就不能到达千里。良马跳一下不能走十步，劣马拉车十天，成功在于不停。", shangxi: "文章以大量比喻论证学习的重要、积累的作用和坚持的意义，结构严密，语言富有说服力。"),
        item("师说", "韩愈", nil, remark: "学者：求学的人。所以：用来……的。受：同“授”，传授。庸：岂、哪。术业：学术技艺。", translation: "古代求学的人一定有老师。老师，是用来传授道理、教授学业、解答疑难的人。人不是生下来就懂得道理，谁能没有疑惑？有疑惑却不跟从老师学习，那些疑惑最终不能解决。因此无论贵贱长幼，道存在的地方，就是老师存在的地方。弟子不一定不如老师，老师也不一定比弟子贤能，听闻道理有先有后，学术技艺各有专门研究罢了。", shangxi: "文章针对当时耻于从师的风气，提出尊师重道和能者为师的观点，论辩锋利，影响深远。"),
        item("赤壁赋", "苏轼", nil, remark: "既望：农历十六。属：劝酒。少焉：一会儿。斗牛：星宿名。冯虚御风：凌空乘风。袅袅：声音婉转悠长。", translation: "壬戌年秋天七月十六日，苏轼和客人在赤壁下泛舟。清风慢慢吹来，水面没有波澜。月亮从东山升起，在斗宿和牛宿之间徘徊。白茫茫的水汽横在江面，水光接连天际。任凭小船飘向哪里，越过茫茫江面，像凌空乘风而不知停在何处，飘飘然像离开人世、成仙登天。客人吹洞箫应和歌声，箫声婉转，如怨如慕，如泣如诉，余音悠长不断。", shangxi: "文章由清风明月写到人生思考，在主客问答中由悲转达，表现苏轼旷达超脱的精神境界。"),
        item("阿房宫赋", "杜牧", nil, remark: "毕：完结，指灭亡。兀：山秃。缦回：曲折回环。钩心斗角：宫室结构参差错落。囷囷：曲折回旋的样子。", translation: "六国灭亡，天下统一，蜀山树木被砍光，阿房宫建成。它覆盖三百多里，遮天蔽日。从骊山向北建造又向西折去，直通咸阳。五步一楼，十步一阁，长廊曲折，屋檐高挑；各随地势，结构精巧。宫殿盘旋曲折，如蜂房水涡，密密层层不知道有多少座。", shangxi: "赋文铺陈阿房宫的奢华，最终借秦亡警示后人，语言夸张瑰丽，讽谏意味强烈。"),
        item("六国论", "苏洵", nil, remark: "兵：兵器。弊：弊病。赂：贿赂、割地求和。互丧：相继灭亡。完：保全。", translation: "六国灭亡，不是兵器不锋利、作战不善，弊病在于割地贿赂秦国。贿赂秦国使自己的力量亏损，这是灭亡的道路。不贿赂秦国的国家也因为贿赂秦国的国家而灭亡，因为失去强有力的援助，不能独自保全。所以说弊病在于贿赂秦国。", shangxi: "文章借六国史事议论现实，中心论点鲜明，层层推进，具有强烈的政治警示意味。"),
        item("登泰山记", "姚鼐", nil, remark: "阳：山南水北。阴：山北水南。磴：石阶。限：界限。", translation: "泰山南面汶水向西流，北面济水向东流。南面山谷的水都流入汶水，北面山谷的水都流入济水。南北分界处是古长城，最高的日观峰在长城南十五里。我在乾隆三十九年十二月从京城冒风雪出发，经过多地，从泰山西北谷进入，越过长城界限，到达泰安。", shangxi: "文章记登泰山经过和日出景象，叙事准确，写景简洁，体现桐城派散文雅洁风格。"),
        item("屈原列传 节选", "司马迁", nil, remark: "疾：痛心。聪：明察。谗谄：说坏话、阿谀的人。离忧：遭遇忧患。约：简约。微：含蓄精深。", translation: "屈原痛心楚王听信不明、谗佞蒙蔽视听、邪恶损害公正、正直不被容纳，所以忧愁深思而写成《离骚》。《离骚》就是遭遇忧患的意思。文章语言简约，辞意含蓄，志向高洁，行为廉正；所写事物虽小，旨意却极大，列举事例虽近，表达意义却深远。", shangxi: "司马迁以深切同情评价屈原人格和作品，既写政治遭遇，也赞美其高洁精神。"),
        item("报任安书 节选", "司马迁", nil, remark: "摩灭：磨灭。倜傥：卓越不凡。膑脚：受膑刑。大底：大抵。发愤：抒发愤懑。", translation: "古代富贵却姓名磨灭的人数不胜数，只有卓越不凡的人被后世称道。周文王被拘禁而推演《周易》，孔子困厄而作《春秋》，屈原被放逐才写《离骚》，左丘明失明而有《国语》，孙膑受刑而修成兵法。大抵《诗》三百篇，也是圣贤抒发愤懑而写成的。", shangxi: "节选以历史人物遭困而著书立说说明忍辱著史的价值，情感沉郁而意志坚韧。"),
        item("归去来兮辞 并序", "陶渊明", nil, remark: "胡不归：为什么不回去。心为形役：心志被形体役使。谏：挽回。追：补救。衡宇：简陋房屋。三径：庭中小路。", translation: "回去吧，田园快要荒芜了，为什么还不回去？既然自己让心志受形体役使，为什么还惆怅独自悲伤？认识到过去的错误已经不能挽回，知道未来还可以补救。船轻轻飘荡，风吹动衣襟。看到家门，我又高兴又奔跑。仆人欢迎，孩子在门口等候，小路虽然荒芜，松菊还在。", shangxi: "作品写辞官归田的喜悦，表现陶渊明摆脱束缚、回归自然本性的追求。"),
        item("种树郭橐驼传", "柳宗元", nil, remark: "橐驼：骆驼。病偻：患驼背病。业：以……为职业。实：结果实。蕃：多。", translation: "郭橐驼不知道原来叫什么。他患驼背病，背隆起弯着腰走路，很像骆驼，所以乡里人叫他橐驼。他听后说很好，这名字确实合适，于是也自称橐驼。他以种树为业，长安富贵人家凡是为观赏或卖果而种树的，都争着雇用他。他种的树无论移栽不移栽，没有不成活的，而且长得高大茂盛，结果又早又多。", shangxi: "文章借种树之道讽喻为官治民要顺应自然、少扰百姓，寓言色彩浓厚。"),
        item("石钟山记", "苏轼", nil, remark: "彭蠡：鄱阳湖。鼓浪：激荡波浪。搏：撞击。钟磬：古代乐器。桴：鼓槌。", translation: "《水经》说鄱阳湖口有石钟山。郦道元认为山下临深潭，微风激浪，水石相击，声音像洪钟。这个说法人们常常怀疑。如今把钟磬放在水中，即使大风浪也不能使它发声，何况石头呢？唐代李渤寻访遗迹，在潭边找到两块石头，敲击听声音，自以为得到了原因，但我更加怀疑这个说法。", shangxi: "文章围绕石钟山得名展开考察，强调实地调查和独立思考，体现苏轼求真辨疑的精神。"),
        item("五代史伶官传序", "欧阳修", nil, remark: "原：推究。人事：人的作为。遗恨：留下的仇恨。少牢：祭品。负：背着。", translation: "唉！盛衰的道理，虽说是天命，难道不是人的作为造成的吗？推究庄宗得天下和失天下的原因，就可以知道了。晋王临终时把三支箭赐给庄宗，告诉他梁、燕王、契丹都是遗恨，要他不要忘记父亲的志向。庄宗收下后藏在宗庙。后来用兵，就派官员用少牢祭告宗庙，取出箭装在锦囊里，背着在军前驱驰。", shangxi: "序文通过庄宗兴亡说明忧劳可以兴国、逸豫可以亡身，史论结合，警策深刻。"),
        item("关雎", "诗经", nil, remark: "窈窕：美好文静。逑：配偶。", translation: "雎鸠在河洲鸣叫，美好文静的女子是君子的好配偶；男子日夜思慕，想以琴瑟钟鼓表达爱慕。", shangxi: "诗以水鸟起兴，写真挚而有节制的爱情追求。"),
        item("蒹葭", "诗经", nil, remark: "蒹葭：芦苇。溯洄：逆流而上。", translation: "芦苇苍苍，白露成霜，所思念的人仿佛在水一方；追寻她道路艰难，顺流望去又像在水中央。", shangxi: "诗反复咏叹追寻不得的怅惘，意境朦胧优美。"),
        item("观沧海", "曹操", nil, remark: "澹澹：水波荡漾。竦峙：高高耸立。", translation: "登上碣石观看大海，海水荡漾，山岛高立；日月星河仿佛都在海中运行，气象壮阔。", shangxi: "诗以大海包容日月星汉的想象，表现雄浑胸襟和统一天下的气概。"),
        item("饮酒", "陶渊明", nil, remark: "尔：这样。真意：人生自然真趣。", translation: "居住在人间却没有车马喧嚣，因为心远自然地方偏静；采菊东篱下，悠然看见南山，其中有真意，却难以言说。", shangxi: "诗表现诗人远离世俗、回归自然的恬淡心境。"),
        item("次北固山下", "王湾", nil, remark: "次：停宿。残夜：夜将尽时。", translation: "旅途在青山外，船行绿水前；潮平岸阔，风正帆悬，海日生于残夜，江春进入旧年。", shangxi: "诗写江南早春行旅，景中含时序更替和思乡之情。"),
        item("使至塞上", "王维", nil, remark: "征蓬：随风飘飞的蓬草，比喻自己。候骑：侦察骑兵。", translation: "我轻车前往边塞，像蓬草飞出汉塞、归雁进入胡天；大漠孤烟直上，长河落日浑圆。", shangxi: "诗以壮阔边塞景象写孤寂旅程，名句雄浑开阔。"),
        item("行路难", "李白", nil, remark: "珍羞：珍贵菜肴。云帆：高高的船帆。", translation: "美酒佳肴在前却难以下咽，拔剑四顾心中茫然；虽然道路艰险，但终有乘风破浪、扬帆沧海的一天。", shangxi: "诗写仕途受阻后的苦闷与自信，情感跌宕而昂扬。"),
        item("黄鹤楼", "崔颢", nil, remark: "历历：分明的样子。萋萋：草木茂盛。", translation: "仙人已乘黄鹤离去，只留下黄鹤楼；晴川树木历历可见，芳草连绵，日暮烟波使人思乡。", shangxi: "诗由传说写到眼前景象，末句以乡愁收束，意境苍茫。"),
        item("望岳", "杜甫", nil, remark: "岱宗：泰山。决眦：睁大眼睛。", translation: "泰山怎样雄伟？齐鲁大地都映着它的青色；登上最高处远望，群山都会显得渺小。", shangxi: "诗写青年杜甫面对泰山的壮志，表现昂扬进取精神。"),
        item("春望", "杜甫", nil, remark: "烽火：战火。簪：束发用的簪子。", translation: "国都沦陷而山河依旧，春城草木深密；感时伤别，连花鸟也令人落泪惊心，战火连月，家书抵万金。", shangxi: "诗把国家破败和个人离愁交织，沉痛真切。"),
        item("登高", "杜甫", nil, remark: "渚：水中小洲。潦倒：衰颓失意。", translation: "风急天高，猿声悲哀，落叶无边而长江滚滚；万里漂泊悲秋，年老多病登台，艰难潦倒中更添愁绪。", shangxi: "诗以宏阔秋景承载身世之悲，被称为七律名篇。"),
        item("锦瑟", "李商隐", nil, remark: "无端：没有来由。惘然：迷惘怅然。", translation: "锦瑟为何有五十根弦？每一弦一柱都牵动华年追忆；梦蝶、啼鹃、珠泪、玉烟等意象交织，往事只能成为惘然追忆。", shangxi: "诗意朦胧含蓄，借多重典故表达对美好年华和情感的怅惘。"),
        item("水调歌头", "苏轼", nil, remark: "婵娟：美好的月色，也指月亮。", translation: "明月何时有？我举酒问青天；人间有悲欢离合，月亮有阴晴圆缺，只愿亲人长久平安，共赏千里明月。", shangxi: "词由问月写到人生哲理，将离别愁思化为旷达祝愿。"),
        item("念奴娇·赤壁怀古", "苏轼", nil, remark: "风流人物：杰出人物。樯橹：战船。", translation: "大江东去，淘尽千古英雄；赤壁乱石穿空、惊涛拍岸，使人想起周瑜当年的英姿和赤壁大战。", shangxi: "词以壮阔江山怀古，既赞英雄，也抒发人生如梦的感慨。"),
        item("永遇乐·京口北固亭怀古", "辛弃疾", nil, remark: "寄奴：刘裕小名。佛狸：北魏太武帝拓跋焘。", translation: "千古江山已难寻英雄孙权，刘裕北伐气势如虎；如今草率北伐恐重蹈覆辙，词人借历史表达忧国之心。", shangxi: "词用多个历史典故议论现实，沉郁悲壮，体现辛弃疾报国情怀。"),
        item("过零丁洋", "文天祥", nil, remark: "汗青：史册。丹心：赤诚之心。", translation: "国家破碎如风中飘絮，身世浮沉如雨打浮萍；人生自古谁能不死？愿留下赤诚之心照耀史册。", shangxi: "诗在危难中表现宁死不屈的民族气节，末句慷慨激昂。"),
        item("天净沙·秋思", "马致远", nil, remark: "昏鸦：黄昏时归巢的乌鸦。断肠：极度悲伤。", translation: "枯藤老树昏鸦，小桥流水人家，古道西风瘦马；夕阳西下，漂泊游子远在天涯。", shangxi: "小令用并列意象营造萧瑟秋景，集中表现游子思乡之悲。"),
        item("山坡羊·潼关怀古", "张养浩", nil, remark: "踌躇：心中不安、感慨万千。", translation: "群山像聚集，波涛像发怒，潼关形势险要；回望古都，宫阙化土，王朝兴亡，受苦的都是百姓。", shangxi: "曲由怀古上升到民生关怀，结尾直白有力。")
    ])

    private static func item(_ title: String, _ writer: String, _ firstLine: String?, remark: String, translation: String, shangxi: String) -> (String, LearningPoemSupplement) {
        (key(title, writer, firstLine), LearningPoemSupplement(remark: remark, translation: translation, shangxi: shangxi))
    }

    private static func key(_ title: String, _ writer: String, _ firstLine: String?) -> String {
        "\(normalize(title))|\(normalize(writer))|\(signature(firstLine))"
    }

    private static func firstLine(of content: String) -> String? {
        content.split(separator: "\n").first.map(String.init)
    }

    private static func signature(_ value: String?) -> String {
        String(normalize(value ?? "").prefix(10))
    }

    private static func normalize(_ value: String) -> String {
        value
            .replacingOccurrences(of: "·", with: "")
            .replacingOccurrences(of: "・", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "　", with: "")
            .replacingOccurrences(of: "，", with: "")
            .replacingOccurrences(of: "。", with: "")
            .replacingOccurrences(of: "？", with: "")
            .replacingOccurrences(of: "！", with: "")
            .replacingOccurrences(of: "；", with: "")
            .replacingOccurrences(of: "、", with: "")
            .replacingOccurrences(of: "難", with: "难")
            .replacingOccurrences(of: "夢", with: "梦")
            .replacingOccurrences(of: "遊", with: "游")
            .replacingOccurrences(of: "歸", with: "归")
            .replacingOccurrences(of: "園", with: "园")
            .replacingOccurrences(of: "臺", with: "台")
            .replacingOccurrences(of: "嶽", with: "岳")
    }
}

private struct GaokaoLearningModuleDetailView: View {
    let module: LearningModule
    @State private var navigationController: UINavigationController?

    var body: some View {
        GaokaoQuestionListView(onSelect: pushQuestion)
            .navigationTitle(module.title)
            .navigationBarTitleDisplayMode(.inline)
            .background(
                NavigationControllerReader { navigationController in
                    self.navigationController = navigationController
                }
            )
    }

    private func pushQuestion(_ question: GaokaoPoetryQuestion) {
        let hostingController = UIHostingController(rootView: GaokaoQuestionDetailView(question: question))
        hostingController.title = question.poemTitle
        hostingController.hidesBottomBarWhenPushed = true
        (navigationController ?? LearningNavigationResolver.findNavigationController())?.pushViewController(hostingController, animated: true)
    }
}

private enum LearningNavigationResolver {
    static func findNavigationController() -> UINavigationController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return nil
        }

        return scene.windows.first(where: { $0.isKeyWindow })?.rootViewController?.learningNearestNavigationController
    }
}

private extension UIViewController {
    var learningNearestNavigationController: UINavigationController? {
        if let navigationController = self as? UINavigationController {
            return navigationController
        }

        if let navigationController = navigationController {
            return navigationController
        }

        for child in children {
            if let navigationController = child.learningNearestNavigationController {
                return navigationController
            }
        }

        return presentedViewController?.learningNearestNavigationController
    }
}

private struct LearningModuleSummary: View {
    let module: LearningModule
    let poemCount: Int

    var body: some View {
        HStack(spacing: AppTheme.spacing_md) {
            Image(systemName: module.icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(module.accentColor)
                .cornerRadius(AppTheme.cornerRadius_md)

            VStack(alignment: .leading, spacing: AppTheme.spacing_xs) {
                Text(module.subtitle)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textPrimary)
                Text("当前已收录 \(poemCount) 篇，点开详情时按需补全文与释义")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .padding(AppTheme.spacing_lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadius_md)
        .padding(.horizontal, AppTheme.spacing_lg)
        .padding(.vertical, AppTheme.spacing_md)
    }
}

private struct PoemLearningRow: View {
    let poem: Poem

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing_sm) {
            HStack {
                Text(poem.title)
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppTheme.textSecondary)
            }

            Text("[\(poem.dynasty)] \(poem.writer)")
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)

            if let tags = poem.tags, !tags.isEmpty {
                Text(tags.prefix(3).joined(separator: " · "))
                    .font(.caption)
                    .foregroundColor(AppTheme.primaryColor)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, AppTheme.spacing_xs)
    }
}

private struct LearningEmptyState: View {
    let module: LearningModule

    var body: some View {
        VStack(spacing: AppTheme.spacing_md) {
            Image(systemName: module.icon)
                .font(.system(size: 42))
                .foregroundColor(module.accentColor)

            Text("暂无\(module.title)数据")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.textPrimary)

            Text("当前模块暂无可展示篇目，请稍后补充内置清单或本地标签。")
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.spacing_xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.backgroundColor.ignoresSafeArea())
    }
}

struct LearningPoemCatalog {
    static let primaryCount = 87
    static let middleSchoolCount = 50
    static let highSchoolCount = 52

    static func poems(for module: LearningModule) -> [Poem] {
        guard module.gradeName != nil else {
            return []
        }

        return uniquePoems(seedPoems(for: module))
    }

    static func resolvedPoem(_ seed: Poem, from poems: [Poem]) -> Poem {
        let matchedPoems = poems.filter { isSamePoem($0, seed) }
        let matchedPoem = matchedPoems.first(where: { contentMatches($0, seed) }) ?? matchedPoems.only

        guard let matchedPoem = matchedPoem else {
            return seed
        }

        guard matchedPoem.content.count > seed.content.count else {
            return seed
        }

        return Poem(
            title: seed.title,
            dynasty: matchedPoem.dynasty,
            writer: matchedPoem.writer,
            content: matchedPoem.content,
            remark: matchedPoem.remark,
            translation: matchedPoem.translation,
            shangxi: matchedPoem.shangxi,
            tags: seed.tags ?? matchedPoem.tags
        )
    }

    private static func isSamePoem(_ lhs: Poem, _ rhs: Poem) -> Bool {
        let lhsTitle = normalized(lhs.title)
        let rhsTitle = normalized(rhs.title)
        let titleMatches = lhsTitle == rhsTitle || lhsTitle.contains(rhsTitle) || rhsTitle.contains(lhsTitle)
        let writerMatches = lhs.writer == rhs.writer || lhs.writer.contains(rhs.writer) || rhs.writer.contains(lhs.writer)
        return titleMatches && writerMatches
    }

    private static func contentMatches(_ lhs: Poem, _ rhs: Poem) -> Bool {
        guard let firstLine = rhs.content.split(separator: "\n").first else {
            return true
        }

        let marker = String(firstLine.prefix(6))
        return marker.isEmpty || lhs.content.contains(marker)
    }

    private static func normalized(_ value: String) -> String {
        value
            .replacingOccurrences(of: "·", with: "")
            .replacingOccurrences(of: "・", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "　", with: "")
            .replacingOccurrences(of: "其一", with: "")
            .replacingOccurrences(of: "其二", with: "")
            .replacingOccurrences(of: "其四", with: "")
            .replacingOccurrences(of: "難", with: "难")
            .replacingOccurrences(of: "夢", with: "梦")
            .replacingOccurrences(of: "遊", with: "游")
            .replacingOccurrences(of: "歸", with: "归")
            .replacingOccurrences(of: "園", with: "园")
            .replacingOccurrences(of: "臺", with: "台")
            .replacingOccurrences(of: "嶽", with: "岳")
    }

    private static func uniquePoems(_ poems: [Poem]) -> [Poem] {
        var seen = Set<String>()
        var result: [Poem] = []

        for poem in poems {
            let firstLine = poem.content.split(separator: "\n").first.map(String.init) ?? ""
            let key = "\(normalized(poem.title))-\(poem.writer)-\(firstLine)"
            if seen.insert(key).inserted {
                result.append(poem)
            }
        }

        return result
    }

    private static func seedPoems(for module: LearningModule) -> [Poem] {
        switch module {
        case .primary:
            return primaryRequiredPoems
        case .middle:
            return middleSchoolRequiredPoems
        case .high:
            return highSchoolRequiredPoems
        case .gaokao:
            return []
        }
    }

    private static func requiredPoem(_ title: String, _ dynasty: String, _ writer: String, _ content: String, _ tags: [String]) -> Poem {
        Poem(title: title, dynasty: dynasty, writer: writer, content: content, tags: tags)
    }

    static let primaryRequiredPoems: [Poem] = [
        requiredPoem("江南", "汉代", "汉乐府", "江南可采莲，莲叶何田田。\n鱼戏莲叶间。\n鱼戏莲叶东，鱼戏莲叶西，鱼戏莲叶南，鱼戏莲叶北。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("长歌行", "汉代", "汉乐府", "青青园中葵，朝露待日晞。\n阳春布德泽，万物生光辉。\n常恐秋节至，焜黄华叶衰。\n百川东到海，何时复西归？\n少壮不努力，老大徒伤悲。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("敕勒歌", "南北朝", "北朝民歌", "敕勒川，阴山下。\n天似穹庐，笼盖四野。\n天苍苍，野茫茫，风吹草低见牛羊。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("咏鹅", "唐代", "骆宾王", "鹅，鹅，鹅，曲项向天歌。\n白毛浮绿水，红掌拨清波。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("风", "唐代", "李峤", "解落三秋叶，能开二月花。\n过江千尺浪，入竹万竿斜。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("咏柳", "唐代", "贺知章", "碧玉妆成一树高，万条垂下绿丝绦。\n不知细叶谁裁出，二月春风似剪刀。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("回乡偶书", "唐代", "贺知章", "少小离家老大回，乡音无改鬓毛衰。\n儿童相见不相识，笑问客从何处来。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("凉州词", "唐代", "王之涣", "黄河远上白云间，一片孤城万仞山。\n羌笛何须怨杨柳，春风不度玉门关。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("登鹳雀楼", "唐代", "王之涣", "白日依山尽，黄河入海流。\n欲穷千里目，更上一层楼。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("春晓", "唐代", "孟浩然", "春眠不觉晓，处处闻啼鸟。\n夜来风雨声，花落知多少。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("凉州词", "唐代", "王翰", "葡萄美酒夜光杯，欲饮琵琶马上催。\n醉卧沙场君莫笑，古来征战几人回？", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("出塞", "唐代", "王昌龄", "秦时明月汉时关，万里长征人未还。\n但使龙城飞将在，不教胡马度阴山。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("芙蓉楼送辛渐", "唐代", "王昌龄", "寒雨连江夜入吴，平明送客楚山孤。\n洛阳亲友如相问，一片冰心在玉壶。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("鹿柴", "唐代", "王维", "空山不见人，但闻人语响。\n返景入深林，复照青苔上。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("送元二使安西", "唐代", "王维", "渭城朝雨浥轻尘，客舍青青柳色新。\n劝君更尽一杯酒，西出阳关无故人。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("九月九日忆山东兄弟", "唐代", "王维", "独在异乡为异客，每逢佳节倍思亲。\n遥知兄弟登高处，遍插茱萸少一人。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("静夜思", "唐代", "李白", "床前明月光，疑是地上霜。\n举头望明月，低头思故乡。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("古朗月行", "唐代", "李白", "小时不识月，呼作白玉盘。\n又疑瑶台镜，飞在青云端。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("望庐山瀑布", "唐代", "李白", "日照香炉生紫烟，遥看瀑布挂前川。\n飞流直下三千尺，疑是银河落九天。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("赠汪伦", "唐代", "李白", "李白乘舟将欲行，忽闻岸上踏歌声。\n桃花潭水深千尺，不及汪伦送我情。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("黄鹤楼送孟浩然之广陵", "唐代", "李白", "故人西辞黄鹤楼，烟花三月下扬州。\n孤帆远影碧空尽，唯见长江天际流。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("早发白帝城", "唐代", "李白", "朝辞白帝彩云间，千里江陵一日还。\n两岸猿声啼不住，轻舟已过万重山。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("望天门山", "唐代", "李白", "天门中断楚江开，碧水东流至此回。\n两岸青山相对出，孤帆一片日边来。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("别董大", "唐代", "高适", "千里黄云白日曛，北风吹雁雪纷纷。\n莫愁前路无知己，天下谁人不识君？", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("绝句", "唐代", "杜甫", "两个黄鹂鸣翠柳，一行白鹭上青天。\n窗含西岭千秋雪，门泊东吴万里船。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("春夜喜雨", "唐代", "杜甫", "好雨知时节，当春乃发生。\n随风潜入夜，润物细无声。\n野径云俱黑，江船火独明。\n晓看红湿处，花重锦官城。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("绝句", "唐代", "杜甫", "迟日江山丽，春风花草香。\n泥融飞燕子，沙暖睡鸳鸯。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("江畔独步寻花", "唐代", "杜甫", "黄师塔前江水东，春光懒困倚微风。\n桃花一簇开无主，可爱深红爱浅红？", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("枫桥夜泊", "唐代", "张继", "月落乌啼霜满天，江枫渔火对愁眠。\n姑苏城外寒山寺，夜半钟声到客船。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("滁州西涧", "唐代", "韦应物", "独怜幽草涧边生，上有黄鹂深树鸣。\n春潮带雨晚来急，野渡无人舟自横。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("渔歌子", "唐代", "张志和", "西塞山前白鹭飞，桃花流水鳜鱼肥。\n青箬笠，绿蓑衣，斜风细雨不须归。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("塞下曲", "唐代", "卢纶", "月黑雁飞高，单于夜遁逃。\n欲将轻骑逐，大雪满弓刀。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("游子吟", "唐代", "孟郊", "慈母手中线，游子身上衣。\n临行密密缝，意恐迟迟归。\n谁言寸草心，报得三春晖。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("早春呈水部张十八员外", "唐代", "韩愈", "天街小雨润如酥，草色遥看近却无。\n最是一年春好处，绝胜烟柳满皇都。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("望洞庭", "唐代", "刘禹锡", "湖光秋月两相和，潭面无风镜未磨。\n遥望洞庭山水翠，白银盘里一青螺。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("浪淘沙", "唐代", "刘禹锡", "九曲黄河万里沙，浪淘风簸自天涯。\n如今直上银河去，同到牵牛织女家。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("赋得古原草送别", "唐代", "白居易", "离离原上草，一岁一枯荣。\n野火烧不尽，春风吹又生。\n远芳侵古道，晴翠接荒城。\n又送王孙去，萋萋满别情。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("池上", "唐代", "白居易", "小娃撑小艇，偷采白莲回。\n不解藏踪迹，浮萍一道开。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("忆江南", "唐代", "白居易", "江南好，风景旧曾谙。\n日出江花红胜火，春来江水绿如蓝。\n能不忆江南？", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("小儿垂钓", "唐代", "胡令能", "蓬头稚子学垂纶，侧坐莓苔草映身。\n路人借问遥招手，怕得鱼惊不应人。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("悯农", "唐代", "李绅", "锄禾日当午，汗滴禾下土。\n谁知盘中餐，粒粒皆辛苦。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("悯农", "唐代", "李绅", "春种一粒粟，秋收万颗子。\n四海无闲田，农夫犹饿死。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("江雪", "唐代", "柳宗元", "千山鸟飞绝，万径人踪灭。\n孤舟蓑笠翁，独钓寒江雪。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("寻隐者不遇", "唐代", "贾岛", "松下问童子，言师采药去。\n只在此山中，云深不知处。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("山行", "唐代", "杜牧", "远上寒山石径斜，白云生处有人家。\n停车坐爱枫林晚，霜叶红于二月花。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("清明", "唐代", "杜牧", "清明时节雨纷纷，路上行人欲断魂。\n借问酒家何处有？牧童遥指杏花村。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("江南春", "唐代", "杜牧", "千里莺啼绿映红，水村山郭酒旗风。\n南朝四百八十寺，多少楼台烟雨中。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("蜂", "唐代", "罗隐", "不论平地与山尖，无限风光尽被占。\n采得百花成蜜后，为谁辛苦为谁甜？", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("江上渔者", "宋代", "范仲淹", "江上往来人，但爱鲈鱼美。\n君看一叶舟，出没风波里。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("元日", "宋代", "王安石", "爆竹声中一岁除，春风送暖入屠苏。\n千门万户曈曈日，总把新桃换旧符。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("泊船瓜洲", "宋代", "王安石", "京口瓜洲一水间，钟山只隔数重山。\n春风又绿江南岸，明月何时照我还。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("书湖阴先生壁", "宋代", "王安石", "茅檐长扫净无苔，花木成畦手自栽。\n一水护田将绿绕，两山排闼送青来。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("六月二十七日望湖楼醉书", "宋代", "苏轼", "黑云翻墨未遮山，白雨跳珠乱入船。\n卷地风来忽吹散，望湖楼下水如天。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("饮湖上初晴后雨", "宋代", "苏轼", "水光潋滟晴方好，山色空蒙雨亦奇。\n欲把西湖比西子，淡妆浓抹总相宜。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("惠崇春江晚景", "宋代", "苏轼", "竹外桃花三两枝，春江水暖鸭先知。\n蒌蒿满地芦芽短，正是河豚欲上时。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("题西林壁", "宋代", "苏轼", "横看成岭侧成峰，远近高低各不同。\n不识庐山真面目，只缘身在此山中。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("夏日绝句", "宋代", "李清照", "生当作人杰，死亦为鬼雄。\n至今思项羽，不肯过江东。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("三衢道中", "宋代", "曾几", "梅子黄时日日晴，小溪泛尽却山行。\n绿阴不减来时路，添得黄鹂四五声。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("示儿", "宋代", "陆游", "死去元知万事空，但悲不见九州同。\n王师北定中原日，家祭无忘告乃翁。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("秋夜将晓出篱门迎凉有感", "宋代", "陆游", "三万里河东入海，五千仞岳上摩天。\n遗民泪尽胡尘里，南望王师又一年。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("四时田园杂兴", "宋代", "范成大", "昼出耘田夜绩麻，村庄儿女各当家。\n童孙未解供耕织，也傍桑阴学种瓜。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("四时田园杂兴", "宋代", "范成大", "梅子金黄杏子肥，麦花雪白菜花稀。\n日长篱落无人过，惟有蜻蜓蛱蝶飞。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("小池", "宋代", "杨万里", "泉眼无声惜细流，树阴照水爱晴柔。\n小荷才露尖尖角，早有蜻蜓立上头。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("晓出净慈寺送林子方", "宋代", "杨万里", "毕竟西湖六月中，风光不与四时同。\n接天莲叶无穷碧，映日荷花别样红。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("春日", "宋代", "朱熹", "胜日寻芳泗水滨，无边光景一时新。\n等闲识得东风面，万紫千红总是春。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("观书有感", "宋代", "朱熹", "半亩方塘一鉴开，天光云影共徘徊。\n问渠那得清如许？为有源头活水来。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("题临安邸", "宋代", "林升", "山外青山楼外楼，西湖歌舞几时休？\n暖风熏得游人醉，直把杭州作汴州。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("游园不值", "宋代", "叶绍翁", "应怜屐齿印苍苔，小扣柴扉久不开。\n春色满园关不住，一枝红杏出墙来。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("乡村四月", "宋代", "翁卷", "绿遍山原白满川，子规声里雨如烟。\n乡村四月闲人少，才了蚕桑又插田。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("墨梅", "元代", "王冕", "我家洗砚池头树，朵朵花开淡墨痕。\n不要人夸好颜色，只留清气满乾坤。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("石灰吟", "明代", "于谦", "千锤万凿出深山，烈火焚烧若等闲。\n粉骨碎身浑不怕，要留清白在人间。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("竹石", "清代", "郑燮", "咬定青山不放松，立根原在破岩中。\n千磨万击还坚劲，任尔东西南北风。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("所见", "清代", "袁枚", "牧童骑黄牛，歌声振林樾。\n意欲捕鸣蝉，忽然闭口立。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("己亥杂诗", "清代", "龚自珍", "九州生气恃风雷，万马齐喑究可哀。\n我劝天公重抖擞，不拘一格降人才。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("村居", "清代", "高鼎", "草长莺飞二月天，拂堤杨柳醉春烟。\n儿童散学归来早，忙趁东风放纸鸢。", ["小学必背诗文", "义务课标2022", "1-6年级"]),
        requiredPoem("司马光", "宋代", "佚名", "群儿戏于庭，一儿登瓮，足跌没水中。\n众皆弃去，光持石击瓮破之，水迸，儿得活。", ["小学必背诗文", "文言文", "课内常见"]),
        requiredPoem("守株待兔", "先秦", "韩非", "宋人有耕者。\n田中有株。\n兔走触株，折颈而死。\n因释其耒而守株，冀复得兔。\n兔不可复得，而身为宋国笑。", ["小学必背诗文", "文言文", "寓言"]),
        requiredPoem("精卫填海", "先秦", "山海经", "炎帝之少女，名曰女娃。\n女娃游于东海，溺而不返，故为精卫。\n常衔西山之木石，以堙于东海。", ["小学必背诗文", "文言文", "神话"]),
        requiredPoem("王戎不取道旁李", "南朝宋", "刘义庆", "王戎七岁，尝与诸小儿游。\n看道边李树多子折枝，诸儿竞走取之，唯戎不动。\n人问之，答曰：树在道边而多子，此必苦李。\n取之，信然。", ["小学必背诗文", "文言文", "课内常见"]),
        requiredPoem("囊萤夜读", "唐代", "晋书", "胤恭勤不倦，博学多通。\n家贫不常得油，夏月则练囊盛数十萤火以照书，以夜继日焉。", ["小学必背诗文", "文言文", "勤学"]),
        requiredPoem("铁杵成针", "宋代", "祝穆", "磨针溪，在象耳山下。\n世传李太白读书山中，未成，弃去。\n过是溪，逢老媪方磨铁杵。\n问之，曰：欲作针。\n太白感其意，还卒业。", ["小学必背诗文", "文言文", "勤学"]),
        requiredPoem("少年中国说 节选", "近现代", "梁启超", "故今日之责任，不在他人，而全在我少年。\n少年智则国智，少年富则国富。\n少年强则国强，少年独立则国独立。\n少年自由则国自由，少年进步则国进步。\n红日初升，其道大光。\n河出伏流，一泻汪洋。\n潜龙腾渊，鳞爪飞扬。\n乳虎啸谷，百兽震惶。", ["小学必背诗文", "课内常见", "近现代文"]),
        requiredPoem("学弈", "先秦", "孟子", "弈秋，通国之善弈者也。\n使弈秋诲二人弈，其一人专心致志，惟弈秋之为听。\n一人虽听之，一心以为有鸿鹄将至，思援弓缴而射之。\n虽与之俱学，弗若之矣。\n为是其智弗若与？曰：非然也。", ["小学必背诗文", "文言文", "课内常见"]),
        requiredPoem("两小儿辩日", "先秦", "列子", "孔子东游，见两小儿辩斗，问其故。\n一儿曰：我以日始出时去人近，而日中时远也。\n一儿曰：我以日初出远，而日中时近也。\n一儿曰：日初出大如车盖，及日中则如盘盂，此不为远者小而近者大乎？\n一儿曰：日初出沧沧凉凉，及其日中如探汤，此不为近者热而远者凉乎？\n孔子不能决也。\n两小儿笑曰：孰为汝多知乎？", ["小学必背诗文", "文言文", "课内常见"]),
        requiredPoem("伯牙鼓琴", "先秦", "吕氏春秋", "伯牙鼓琴，锺子期听之。\n方鼓琴而志在太山，锺子期曰：善哉乎鼓琴，巍巍乎若太山。\n少选之间而志在流水，锺子期又曰：善哉乎鼓琴，汤汤乎若流水。\n锺子期死，伯牙破琴绝弦，终身不复鼓琴，以为世无足复为鼓琴者。", ["小学必背诗文", "文言文", "知音"]),
        requiredPoem("书戴嵩画牛", "宋代", "苏轼", "蜀中有杜处士，好书画，所宝以百数。\n有戴嵩牛一轴，尤所爱，锦囊玉轴，常以自随。\n一日曝书画，有一牧童见之，拊掌大笑。\n曰：此画斗牛也。\n牛斗，力在角，尾搐入两股间，今乃掉尾而斗，谬矣。\n处士笑而然之。\n古语有云：耕当问奴，织当问婢，不可改也。", ["小学必背诗文", "文言文", "课内常见"]),
        requiredPoem("杨氏之子", "南朝梁", "刘义庆", "梁国杨氏子九岁，甚聪惠。\n孔君平诣其父，父不在，乃呼儿出。\n为设果，果有杨梅。\n孔指以示儿曰：此是君家果。\n儿应声答曰：未闻孔雀是夫子家禽。", ["小学必背诗文", "文言文", "课内常见"])
    ]

    static let highSchoolRequiredPoems: [Poem] = [
        requiredPoem("劝学", "先秦", "荀子", "君子曰：学不可以已。\n青，取之于蓝，而青于蓝；冰，水为之，而寒于水。\n木直中绳，輮以为轮，其曲中规。\n虽有槁暴，不复挺者，輮使之然也。\n故木受绳则直，金就砺则利。\n君子博学而日参省乎己，则知明而行无过矣。\n积土成山，风雨兴焉；积水成渊，蛟龙生焉。\n积善成德，而神明自得，圣心备焉。\n故不积跬步，无以至千里；不积小流，无以成江海。\n骐骥一跃，不能十步；驽马十驾，功在不舍。", ["高中必背诗文", "文言文", "课标常见"]),
        requiredPoem("师说", "唐代", "韩愈", "古之学者必有师。\n师者，所以传道受业解惑也。\n人非生而知之者，孰能无惑？\n惑而不从师，其为惑也，终不解矣。\n生乎吾前，其闻道也固先乎吾，吾从而师之。\n生乎吾后，其闻道也亦先乎吾，吾从而师之。\n吾师道也，夫庸知其年之先后生于吾乎？\n是故无贵无贱，无长无少，道之所存，师之所存也。\n是故弟子不必不如师，师不必贤于弟子。\n闻道有先后，术业有专攻，如是而已。", ["高中必背诗文", "文言文", "课标常见"]),
        requiredPoem("赤壁赋", "宋代", "苏轼", "壬戌之秋，七月既望，苏子与客泛舟游于赤壁之下。\n清风徐来，水波不兴。\n举酒属客，诵明月之诗，歌窈窕之章。\n少焉，月出于东山之上，徘徊于斗牛之间。\n白露横江，水光接天。\n纵一苇之所如，凌万顷之茫然。\n浩浩乎如冯虚御风，而不知其所止。\n飘飘乎如遗世独立，羽化而登仙。\n客有吹洞箫者，倚歌而和之。\n其声呜呜然，如怨如慕，如泣如诉。\n余音袅袅，不绝如缕。", ["高中必背诗文", "文言文", "苏轼"]),
        requiredPoem("阿房宫赋", "唐代", "杜牧", "六王毕，四海一，蜀山兀，阿房出。\n覆压三百余里，隔离天日。\n骊山北构而西折，直走咸阳。\n二川溶溶，流入宫墙。\n五步一楼，十步一阁。\n廊腰缦回，檐牙高啄。\n各抱地势，钩心斗角。\n盘盘焉，囷囷焉，蜂房水涡，矗不知其几千万落。\n长桥卧波，未云何龙？复道行空，不霁何虹？\n高低冥迷，不知西东。", ["高中必背诗文", "文言文", "赋"]),
        requiredPoem("六国论", "宋代", "苏洵", "六国破灭，非兵不利，战不善，弊在赂秦。\n赂秦而力亏，破灭之道也。\n或曰：六国互丧，率赂秦耶？\n曰：不赂者以赂者丧，盖失强援，不能独完。\n故曰：弊在赂秦也。\n秦以攻取之外，小则获邑，大则得城。\n较秦之所得，与战胜而得者，其实百倍。\n诸侯之所亡，与战败而亡者，其实亦百倍。\n则秦之所大欲，诸侯之所大患，固不在战矣。", ["高中必背诗文", "文言文", "史论"]),
        requiredPoem("登泰山记", "清代", "姚鼐", "泰山之阳，汶水西流；其阴，济水东流。\n阳谷皆入汶，阴谷皆入济。\n当其南北分者，古长城也。\n最高日观峰，在长城南十五里。\n余以乾隆三十九年十二月，自京师乘风雪，历齐河、长清，穿泰山西北谷，越长城之限，至于泰安。\n是月丁未，与知府朱孝纯子颍由南麓登。\n四十五里，道皆砌石为磴，其级七千有余。\n泰山正南面有三谷，中谷绕泰安城下，郦道元所谓环水也。", ["高中必背诗文", "文言文", "游记"]),
        requiredPoem("屈原列传 节选", "汉代", "司马迁", "屈平疾王听之不聪也，谗谄之蔽明也，邪曲之害公也，方正之不容也。\n故忧愁幽思而作《离骚》。\n离骚者，犹离忧也。\n夫天者，人之始也；父母者，人之本也。\n人穷则反本，故劳苦倦极，未尝不呼天也。\n疾痛惨怛，未尝不呼父母也。\n其文约，其辞微，其志洁，其行廉。\n其称文小而其指极大，举类迩而见义远。", ["高中必背诗文", "文言文", "史记"]),
        requiredPoem("报任安书 节选", "汉代", "司马迁", "古者富贵而名摩灭，不可胜记，唯倜傥非常之人称焉。\n盖文王拘而演《周易》；仲尼厄而作《春秋》；屈原放逐，乃赋《离骚》。\n左丘失明，厥有《国语》；孙子膑脚，《兵法》修列。\n不韦迁蜀，世传《吕览》；韩非囚秦，《说难》《孤愤》。\n《诗》三百篇，大底圣贤发愤之所为作也。\n此人皆意有所郁结，不得通其道，故述往事，思来者。", ["高中必背诗文", "文言文", "史记"]),
        requiredPoem("归去来兮辞 并序", "东晋", "陶渊明", "归去来兮，田园将芜胡不归？\n既自以心为形役，奚惆怅而独悲？\n悟已往之不谏，知来者之可追。\n实迷途其未远，觉今是而昨非。\n舟遥遥以轻飏，风飘飘而吹衣。\n问征夫以前路，恨晨光之熹微。\n乃瞻衡宇，载欣载奔。\n僮仆欢迎，稚子候门。\n三径就荒，松菊犹存。\n携幼入室，有酒盈樽。", ["高中必背诗文", "文言文", "辞赋"]),
        requiredPoem("种树郭橐驼传", "唐代", "柳宗元", "郭橐驼，不知始何名。\n病偻，隆然伏行，有类橐驼者，故乡人号之驼。\n驼闻之曰：甚善，名我固当。\n因舍其名，亦自谓橐驼云。\n其乡曰丰乐乡，在长安西。\n驼业种树，凡长安豪富人为观游及卖果者，皆争迎取养。\n视驼所种树，或移徙，无不活；且硕茂，早实以蕃。\n他植者虽窥伺效慕，莫能如也。", ["高中必背诗文", "文言文", "柳宗元"]),
        requiredPoem("石钟山记", "宋代", "苏轼", "《水经》云：彭蠡之口有石钟山焉。\n郦元以为下临深潭，微风鼓浪，水石相搏，声如洪钟。\n是说也，人常疑之。\n今以钟磬置水中，虽大风浪不能鸣也，而况石乎！\n至唐李渤始访其遗踪，得双石于潭上。\n扣而聆之，南声函胡，北音清越，桴止响腾，余韵徐歇。\n自以为得之矣。\n然是说也，余尤疑之。", ["高中必背诗文", "文言文", "苏轼"]),
        requiredPoem("五代史伶官传序", "宋代", "欧阳修", "呜呼！盛衰之理，虽曰天命，岂非人事哉！\n原庄宗之所以得天下，与其所以失之者，可以知之矣。\n世言晋王之将终也，以三矢赐庄宗而告之曰：梁，吾仇也；燕王，吾所立；契丹与吾约为兄弟，而皆背晋以归梁。\n此三者，吾遗恨也。\n与尔三矢，尔其无忘乃父之志。\n庄宗受而藏之于庙。\n其后用兵，则遣从事以一少牢告庙，请其矢，盛以锦囊，负而前驱。", ["高中必背诗文", "文言文", "史论"]),
        Poem(title: "静女", dynasty: "先秦", writer: "诗经", content: "静女其姝，俟我于城隅。\n爱而不见，搔首踟蹰。\n静女其娈，贻我彤管。\n彤管有炜，说怿女美。\n自牧归荑，洵美且异。\n匪女之为美，美人之贻。", tags: ["高中必背诗文", "诗经", "课标常见"]),
        Poem(title: "无衣", dynasty: "先秦", writer: "诗经", content: "岂曰无衣？与子同袍。\n王于兴师，修我戈矛。与子同仇！\n岂曰无衣？与子同泽。\n王于兴师，修我矛戟。与子偕作！\n岂曰无衣？与子同裳。\n王于兴师，修我甲兵。与子偕行！", tags: ["高中必背诗文", "诗经", "爱国"]),
        Poem(title: "离骚", dynasty: "战国", writer: "屈原", content: "帝高阳之苗裔兮，朕皇考曰伯庸。\n摄提贞于孟陬兮，惟庚寅吾以降。\n皇览揆余初度兮，肇锡余以嘉名。\n名余曰正则兮，字余曰灵均。\n纷吾既有此内美兮，又重之以修能。", tags: ["高中必背诗文", "楚辞", "节选"]),
        Poem(title: "涉江采芙蓉", dynasty: "汉代", writer: "古诗十九首", content: "涉江采芙蓉，兰泽多芳草。\n采之欲遗谁？所思在远道。\n还顾望旧乡，长路漫浩浩。\n同心而离居，忧伤以终老。", tags: ["高中必背诗文", "古诗十九首", "思念"]),
        Poem(title: "短歌行", dynasty: "东汉", writer: "曹操", content: "对酒当歌，人生几何！\n譬如朝露，去日苦多。\n慨当以慷，忧思难忘。\n何以解忧？唯有杜康。\n青青子衿，悠悠我心。\n但为君故，沉吟至今。", tags: ["高中必背诗文", "建安文学", "抒怀"]),
        Poem(title: "归园田居 其一", dynasty: "东晋", writer: "陶渊明", content: "少无适俗韵，性本爱丘山。\n误落尘网中，一去三十年。\n羁鸟恋旧林，池鱼思故渊。\n开荒南野际，守拙归园田。\n方宅十余亩，草屋八九间。", tags: ["高中必背诗文", "田园"]),
        Poem(title: "拟行路难 其四", dynasty: "南朝宋", writer: "鲍照", content: "泻水置平地，各自东西南北流。\n人生亦有命，安能行叹复坐愁！\n酌酒以自宽，举杯断绝歌路难。\n心非木石岂无感？吞声踯躅不敢言。", tags: ["高中必背诗文", "抒怀"]),
        Poem(title: "春江花月夜", dynasty: "唐代", writer: "张若虚", content: "春江潮水连海平，海上明月共潮生。\n滟滟随波千万里，何处春江无月明！\n江流宛转绕芳甸，月照花林皆似霰。\n空里流霜不觉飞，汀上白沙看不见。", tags: ["高中必背诗文", "唐诗", "月"]),
        Poem(title: "山居秋暝", dynasty: "唐代", writer: "王维", content: "空山新雨后，天气晚来秋。\n明月松间照，清泉石上流。\n竹喧归浣女，莲动下渔舟。\n随意春芳歇，王孙自可留。", tags: ["高中必背诗文", "山水田园"]),
        Poem(title: "蜀道难", dynasty: "唐代", writer: "李白", content: "噫吁嚱，危乎高哉！\n蜀道之难，难于上青天！\n蚕丛及鱼凫，开国何茫然！\n尔来四万八千岁，不与秦塞通人烟。\n西当太白有鸟道，可以横绝峨眉巅。", tags: ["高中必背诗文", "李白", "浪漫主义"]),
        Poem(title: "梦游天姥吟留别", dynasty: "唐代", writer: "李白", content: "海客谈瀛洲，烟涛微茫信难求。\n越人语天姥，云霞明灭或可睹。\n天姥连天向天横，势拔五岳掩赤城。\n天台四万八千丈，对此欲倒东南倾。", tags: ["高中必背诗文", "李白", "浪漫主义"]),
        Poem(title: "将进酒", dynasty: "唐代", writer: "李白", content: "君不见，黄河之水天上来，奔流到海不复回。\n君不见，高堂明镜悲白发，朝如青丝暮成雪。\n人生得意须尽欢，莫使金樽空对月。\n天生我材必有用，千金散尽还复来。", tags: ["高中必背诗文", "李白", "乐府"]),
        Poem(title: "燕歌行", dynasty: "唐代", writer: "高适", content: "汉家烟尘在东北，汉将辞家破残贼。\n男儿本自重横行，天子非常赐颜色。\n摐金伐鼓下榆关，旌旆逶迤碣石间。", tags: ["高中必背诗文", "边塞"]),
        Poem(title: "蜀相", dynasty: "唐代", writer: "杜甫", content: "丞相祠堂何处寻？锦官城外柏森森。\n映阶碧草自春色，隔叶黄鹂空好音。\n三顾频烦天下计，两朝开济老臣心。\n出师未捷身先死，长使英雄泪满襟。", tags: ["高中必背诗文", "杜甫", "咏史"]),
        Poem(title: "登高", dynasty: "唐代", writer: "杜甫", content: "风急天高猿啸哀，渚清沙白鸟飞回。\n无边落木萧萧下，不尽长江滚滚来。\n万里悲秋常作客，百年多病独登台。\n艰难苦恨繁霜鬓，潦倒新停浊酒杯。", tags: ["高中必背诗文", "杜甫", "七律"]),
        Poem(title: "客至", dynasty: "唐代", writer: "杜甫", content: "舍南舍北皆春水，但见群鸥日日来。\n花径不曾缘客扫，蓬门今始为君开。\n盘飧市远无兼味，樽酒家贫只旧醅。\n肯与邻翁相对饮，隔篱呼取尽余杯。", tags: ["高中必背诗文", "杜甫", "生活"]),
        Poem(title: "登岳阳楼", dynasty: "唐代", writer: "杜甫", content: "昔闻洞庭水，今上岳阳楼。\n吴楚东南坼，乾坤日夜浮。\n亲朋无一字，老病有孤舟。\n戎马关山北，凭轩涕泗流。", tags: ["高中必背诗文", "杜甫", "忧国"]),
        Poem(title: "琵琶行", dynasty: "唐代", writer: "白居易", content: "浔阳江头夜送客，枫叶荻花秋瑟瑟。\n主人下马客在船，举酒欲饮无管弦。\n醉不成欢惨将别，别时茫茫江浸月。\n忽闻水上琵琶声，主人忘归客不发。", tags: ["高中必背诗文", "白居易", "叙事"]),
        Poem(title: "李凭箜篌引", dynasty: "唐代", writer: "李贺", content: "吴丝蜀桐张高秋，空山凝云颓不流。\n江娥啼竹素女愁，李凭中国弹箜篌。\n昆山玉碎凤凰叫，芙蓉泣露香兰笑。", tags: ["高中必背诗文", "音乐"]),
        requiredPoem("菩萨蛮", "唐代", "温庭筠", "小山重叠金明灭，鬓云欲度香腮雪。\n懒起画蛾眉，弄妆梳洗迟。\n照花前后镜，花面交相映。\n新帖绣罗襦，双双金鹧鸪。", ["高中必背诗文", "普高课标2020", "诗文40首"]),
        Poem(title: "锦瑟", dynasty: "唐代", writer: "李商隐", content: "锦瑟无端五十弦，一弦一柱思华年。\n庄生晓梦迷蝴蝶，望帝春心托杜鹃。\n沧海月明珠有泪，蓝田日暖玉生烟。\n此情可待成追忆？只是当时已惘然。", tags: ["高中必背诗文", "李商隐", "朦胧"]),
        Poem(title: "虞美人", dynasty: "五代", writer: "李煜", content: "春花秋月何时了？往事知多少。\n小楼昨夜又东风，故国不堪回首月明中。\n雕栏玉砌应犹在，只是朱颜改。\n问君能有几多愁？恰似一江春水向东流。", tags: ["高中必背诗文", "词", "亡国"]),
        Poem(title: "望海潮", dynasty: "宋代", writer: "柳永", content: "东南形胜，三吴都会，钱塘自古繁华。\n烟柳画桥，风帘翠幕，参差十万人家。\n云树绕堤沙，怒涛卷霜雪，天堑无涯。", tags: ["高中必背诗文", "宋词", "城市"]),
        Poem(title: "桂枝香·金陵怀古", dynasty: "宋代", writer: "王安石", content: "登临送目，正故国晚秋，天气初肃。\n千里澄江似练，翠峰如簇。\n征帆去棹残阳里，背西风、酒旗斜矗。", tags: ["高中必背诗文", "宋词", "怀古"]),
        Poem(title: "江城子·乙卯正月二十日夜记梦", dynasty: "宋代", writer: "苏轼", content: "十年生死两茫茫，不思量，自难忘。\n千里孤坟，无处话凄凉。\n纵使相逢应不识，尘满面，鬓如霜。", tags: ["高中必背诗文", "宋词", "悼亡"]),
        Poem(title: "念奴娇·赤壁怀古", dynasty: "宋代", writer: "苏轼", content: "大江东去，浪淘尽，千古风流人物。\n故垒西边，人道是，三国周郎赤壁。\n乱石穿空，惊涛拍岸，卷起千堆雪。", tags: ["高中必背诗文", "宋词", "豪放"]),
        Poem(title: "登快阁", dynasty: "宋代", writer: "黄庭坚", content: "痴儿了却公家事，快阁东西倚晚晴。\n落木千山天远大，澄江一道月分明。\n朱弦已为佳人绝，青眼聊因美酒横。\n万里归船弄长笛，此心吾与白鸥盟。", tags: ["高中必背诗文", "宋诗", "抒怀"]),
        Poem(title: "鹊桥仙", dynasty: "宋代", writer: "秦观", content: "纤云弄巧，飞星传恨，银汉迢迢暗度。\n金风玉露一相逢，便胜却人间无数。\n柔情似水，佳期如梦，忍顾鹊桥归路。\n两情若是久长时，又岂在朝朝暮暮。", tags: ["高中必背诗文", "宋词", "爱情"]),
        Poem(title: "苏幕遮", dynasty: "宋代", writer: "周邦彦", content: "燎沉香，消溽暑。\n鸟雀呼晴，侵晓窥檐语。\n叶上初阳干宿雨，水面清圆，一一风荷举。", tags: ["高中必背诗文", "宋词", "写景"]),
        Poem(title: "声声慢", dynasty: "宋代", writer: "李清照", content: "寻寻觅觅，冷冷清清，凄凄惨惨戚戚。\n乍暖还寒时候，最难将息。\n三杯两盏淡酒，怎敌他、晚来风急！", tags: ["高中必背诗文", "宋词", "愁情"]),
        Poem(title: "书愤", dynasty: "宋代", writer: "陆游", content: "早岁那知世事艰，中原北望气如山。\n楼船夜雪瓜洲渡，铁马秋风大散关。\n塞上长城空自许，镜中衰鬓已先斑。\n出师一表真名世，千载谁堪伯仲间！", tags: ["高中必背诗文", "爱国"]),
        Poem(title: "临安春雨初霁", dynasty: "宋代", writer: "陆游", content: "世味年来薄似纱，谁令骑马客京华。\n小楼一夜听春雨，深巷明朝卖杏花。\n矮纸斜行闲作草，晴窗细乳戏分茶。\n素衣莫起风尘叹，犹及清明可到家。", tags: ["高中必背诗文", "宋诗", "抒怀"]),
        Poem(title: "念奴娇·过洞庭", dynasty: "宋代", writer: "张孝祥", content: "洞庭青草，近中秋，更无一点风色。\n玉鉴琼田三万顷，着我扁舟一叶。\n素月分辉，明河共影，表里俱澄澈。", tags: ["高中必背诗文", "宋词", "山水"]),
        Poem(title: "永遇乐·京口北固亭怀古", dynasty: "宋代", writer: "辛弃疾", content: "千古江山，英雄无觅，孙仲谋处。\n舞榭歌台，风流总被雨打风吹去。\n斜阳草树，寻常巷陌，人道寄奴曾住。", tags: ["高中必背诗文", "宋词", "怀古"]),
        Poem(title: "菩萨蛮·书江西造口壁", dynasty: "宋代", writer: "辛弃疾", content: "郁孤台下清江水，中间多少行人泪。\n西北望长安，可怜无数山。\n青山遮不住，毕竟东流去。\n江晚正愁余，山深闻鹧鸪。", tags: ["高中必背诗文", "宋词", "爱国"]),
        Poem(title: "青玉案·元夕", dynasty: "宋代", writer: "辛弃疾", content: "东风夜放花千树，更吹落、星如雨。\n宝马雕车香满路。\n凤箫声动，玉壶光转，一夜鱼龙舞。", tags: ["高中必背诗文", "宋词", "节日"]),
        requiredPoem("贺新郎", "宋代", "刘克庄", "国脉微如缕。\n问长缨何时入手，缚将戎主？\n未必人间无好汉，谁与宽些尺度？\n试看取、当年韩五。\n岂有谷城公付授，也不干曾遇骊山母。\n谈笑起，两河路。\n少时棋柝曾联句。\n叹而今、登楼揽镜，事机频误。\n闻说北风吹面急，边上冲梯屡舞。\n君莫道、投鞭虚语。\n自古一贤能制难，有金汤便可无张许？\n快投笔，莫题柱。", ["高中必背诗文", "普高课标2020", "诗文40首"]),
        Poem(title: "扬州慢", dynasty: "宋代", writer: "姜夔", content: "淮左名都，竹西佳处，解鞍少驻初程。\n过春风十里，尽荠麦青青。\n自胡马窥江去后，废池乔木，犹厌言兵。", tags: ["高中必背诗文", "宋词", "怀古"]),
        Poem(title: "长亭送别", dynasty: "元代", writer: "王实甫", content: "碧云天，黄花地，西风紧，北雁南飞。\n晓来谁染霜林醉？总是离人泪。", tags: ["高中必背诗文", "元曲", "送别"]),
        Poem(title: "朝天子·咏喇叭", dynasty: "明代", writer: "王磐", content: "喇叭，唢呐，曲儿小腔儿大。\n官船来往乱如麻，全仗你抬声价。\n军听了军愁，民听了民怕。\n哪里去辨甚么真共假？\n眼见的吹翻了这家，吹伤了那家，只吹的水尽鹅飞罢！", tags: ["高中必背诗文", "元明清", "讽刺"])
    ]

    static let middleSchoolRequiredPoems: [Poem] = [
        requiredPoem("陋室铭", "唐代", "刘禹锡", "山不在高，有仙则名。\n水不在深，有龙则灵。\n斯是陋室，惟吾德馨。\n苔痕上阶绿，草色入帘青。\n谈笑有鸿儒，往来无白丁。\n可以调素琴，阅金经。\n无丝竹之乱耳，无案牍之劳形。\n南阳诸葛庐，西蜀子云亭。\n孔子云：何陋之有？", ["初中必背诗文", "义务课标2022", "文言文"]),
        requiredPoem("爱莲说", "宋代", "周敦颐", "水陆草木之花，可爱者甚蕃。\n晋陶渊明独爱菊。\n自李唐来，世人甚爱牡丹。\n予独爱莲之出淤泥而不染，濯清涟而不妖。\n中通外直，不蔓不枝。\n香远益清，亭亭净植，可远观而不可亵玩焉。\n予谓菊，花之隐逸者也；牡丹，花之富贵者也；莲，花之君子者也。\n噫！菊之爱，陶后鲜有闻。\n莲之爱，同予者何人？\n牡丹之爱，宜乎众矣。", ["初中必背诗文", "义务课标2022", "文言文"]),
        requiredPoem("三峡", "南北朝", "郦道元", "自三峡七百里中，两岸连山，略无阙处。\n重岩叠嶂，隐天蔽日，自非亭午夜分，不见曦月。\n至于夏水襄陵，沿溯阻绝。\n或王命急宣，有时朝发白帝，暮到江陵，其间千二百里，虽乘奔御风，不以疾也。\n春冬之时，则素湍绿潭，回清倒影。\n绝巘多生怪柏，悬泉瀑布，飞漱其间。\n清荣峻茂，良多趣味。\n每至晴初霜旦，林寒涧肃。\n常有高猿长啸，属引凄异，空谷传响，哀转久绝。\n故渔者歌曰：巴东三峡巫峡长，猿鸣三声泪沾裳。", ["初中必背诗文", "义务课标2022", "文言文"]),
        requiredPoem("记承天寺夜游", "宋代", "苏轼", "元丰六年十月十二日夜，解衣欲睡，月色入户，欣然起行。\n念无与为乐者，遂至承天寺寻张怀民。\n怀民亦未寝，相与步于中庭。\n庭下如积水空明，水中藻、荇交横，盖竹柏影也。\n何夜无月？何处无竹柏？但少闲人如吾两人者耳。", ["初中必背诗文", "义务课标2022", "文言文"]),
        requiredPoem("岳阳楼记", "宋代", "范仲淹", "庆历四年春，滕子京谪守巴陵郡。\n越明年，政通人和，百废具兴。\n乃重修岳阳楼，增其旧制，刻唐贤今人诗赋于其上。\n属予作文以记之。\n予观夫巴陵胜状，在洞庭一湖。\n衔远山，吞长江，浩浩汤汤，横无际涯。\n朝晖夕阴，气象万千，此则岳阳楼之大观也。\n然则北通巫峡，南极潇湘，迁客骚人，多会于此。\n览物之情，得无异乎？\n嗟夫！予尝求古仁人之心，或异二者之为，何哉？\n不以物喜，不以己悲。\n居庙堂之高则忧其民，处江湖之远则忧其君。\n先天下之忧而忧，后天下之乐而乐。\n噫！微斯人，吾谁与归？", ["初中必背诗文", "义务课标2022", "文言文"]),
        requiredPoem("醉翁亭记", "宋代", "欧阳修", "环滁皆山也。\n其西南诸峰，林壑尤美，望之蔚然而深秀者，琅琊也。\n山行六七里，渐闻水声潺潺，而泻出于两峰之间者，酿泉也。\n峰回路转，有亭翼然临于泉上者，醉翁亭也。\n作亭者谁？山之僧智仙也。\n名之者谁？太守自谓也。\n太守与客来饮于此，饮少辄醉，而年又最高，故自号曰醉翁也。\n醉翁之意不在酒，在乎山水之间也。\n山水之乐，得之心而寓之酒也。\n若夫日出而林霏开，云归而岩穴暝，晦明变化者，山间之朝暮也。\n野芳发而幽香，佳木秀而繁阴，风霜高洁，水落而石出者，山间之四时也。\n朝而往，暮而归，四时之景不同，而乐亦无穷也。", ["初中必背诗文", "义务课标2022", "文言文"]),
        requiredPoem("出师表", "三国", "诸葛亮", "先帝创业未半而中道崩殂，今天下三分，益州疲弊，此诚危急存亡之秋也。\n然侍卫之臣不懈于内，忠志之士忘身于外者，盖追先帝之殊遇，欲报之于陛下也。\n诚宜开张圣听，以光先帝遗德，恢弘志士之气。\n不宜妄自菲薄，引喻失义，以塞忠谏之路也。\n亲贤臣，远小人，此先汉所以兴隆也；亲小人，远贤臣，此后汉所以倾颓也。\n臣本布衣，躬耕于南阳，苟全性命于乱世，不求闻达于诸侯。\n先帝不以臣卑鄙，猥自枉屈，三顾臣于草庐之中。\n咨臣以当世之事，由是感激，遂许先帝以驱驰。\n受任于败军之际，奉命于危难之间，尔来二十有一年矣。", ["初中必背诗文", "义务课标2022", "文言文"]),
        requiredPoem("桃花源记", "东晋", "陶渊明", "晋太元中，武陵人捕鱼为业。\n缘溪行，忘路之远近。\n忽逢桃花林，夹岸数百步，中无杂树，芳草鲜美，落英缤纷。\n渔人甚异之，复前行，欲穷其林。\n林尽水源，便得一山，山有小口，仿佛若有光。\n便舍船，从口入。\n初极狭，才通人。\n复行数十步，豁然开朗。\n土地平旷，屋舍俨然，有良田、美池、桑竹之属。\n阡陌交通，鸡犬相闻。\n其中往来种作，男女衣着，悉如外人。\n黄发垂髫，并怡然自乐。", ["初中必背诗文", "义务课标2022", "文言文"]),
        requiredPoem("小石潭记", "唐代", "柳宗元", "从小丘西行百二十步，隔篁竹，闻水声，如鸣珮环，心乐之。\n伐竹取道，下见小潭，水尤清冽。\n全石以为底，近岸，卷石底以出，为坻，为屿，为嵁，为岩。\n青树翠蔓，蒙络摇缀，参差披拂。\n潭中鱼可百许头，皆若空游无所依。\n日光下澈，影布石上，佁然不动。\n俶尔远逝，往来翕忽，似与游者相乐。\n潭西南而望，斗折蛇行，明灭可见。\n其岸势犬牙差互，不可知其源。\n坐潭上，四面竹树环合，寂寥无人。\n凄神寒骨，悄怆幽邃。\n以其境过清，不可久居，乃记之而去。", ["初中必背诗文", "义务课标2022", "文言文"]),
        requiredPoem("湖心亭看雪", "明末清初", "张岱", "崇祯五年十二月，余住西湖。\n大雪三日，湖中人鸟声俱绝。\n是日更定矣，余拏一小舟，拥毳衣炉火，独往湖心亭看雪。\n雾凇沆砀，天与云与山与水，上下一白。\n湖上影子，惟长堤一痕、湖心亭一点、与余舟一芥、舟中人两三粒而已。\n到亭上，有两人铺毡对坐，一童子烧酒炉正沸。\n见余大喜曰：湖中焉得更有此人！\n拉余同饮。\n余强饮三大白而别。\n问其姓氏，是金陵人，客此。\n及下船，舟子喃喃曰：莫说相公痴，更有痴似相公者。", ["初中必背诗文", "义务课标2022", "文言文"]),
        requiredPoem("关雎", "先秦", "诗经", "关关雎鸠，在河之洲。\n窈窕淑女，君子好逑。\n参差荇菜，左右流之。\n窈窕淑女，寤寐求之。\n求之不得，寤寐思服。\n悠哉悠哉，辗转反侧。\n参差荇菜，左右采之。\n窈窕淑女，琴瑟友之。\n参差荇菜，左右芼之。\n窈窕淑女，钟鼓乐之。", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("蒹葭", "先秦", "诗经", "蒹葭苍苍，白露为霜。\n所谓伊人，在水一方。\n溯洄从之，道阻且长。\n溯游从之，宛在水中央。\n蒹葭萋萋，白露未晞。\n所谓伊人，在水之湄。\n溯洄从之，道阻且跻。\n溯游从之，宛在水中坻。\n蒹葭采采，白露未已。\n所谓伊人，在水之涘。\n溯洄从之，道阻且右。\n溯游从之，宛在水中沚。", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("十五从军征", "汉代", "汉乐府", "十五从军征，八十始得归。\n道逢乡里人，家中有阿谁？\n遥看是君家，松柏冢累累。\n兔从狗窦入，雉从梁上飞。\n中庭生旅谷，井上生旅葵。\n舂谷持作饭，采葵持作羹。\n羹饭一时熟，不知贻阿谁。\n出门东向看，泪落沾我衣。", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("观沧海", "东汉", "曹操", "东临碣石，以观沧海。\n水何澹澹，山岛竦峙。\n树木丛生，百草丰茂。\n秋风萧瑟，洪波涌起。\n日月之行，若出其中。\n星汉灿烂，若出其里。\n幸甚至哉，歌以咏志。", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("饮酒", "东晋", "陶渊明", "结庐在人境，而无车马喧。\n问君何能尔？心远地自偏。\n采菊东篱下，悠然见南山。\n山气日夕佳，飞鸟相与还。\n此中有真意，欲辨已忘言。", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("木兰辞", "南北朝", "北朝民歌", "唧唧复唧唧，木兰当户织。\n不闻机杼声，唯闻女叹息。\n问女何所思，问女何所忆。\n女亦无所思，女亦无所忆。\n昨夜见军帖，可汗大点兵。\n军书十二卷，卷卷有爷名。\n阿爷无大儿，木兰无长兄。\n愿为市鞍马，从此替爷征。\n东市买骏马，西市买鞍鞯，南市买辔头，北市买长鞭。\n旦辞爷娘去，暮宿黄河边。\n不闻爷娘唤女声，但闻黄河流水鸣溅溅。\n旦辞黄河去，暮至黑山头。\n不闻爷娘唤女声，但闻燕山胡骑鸣啾啾。\n万里赴戎机，关山度若飞。\n朔气传金柝，寒光照铁衣。\n将军百战死，壮士十年归。\n归来见天子，天子坐明堂。\n策勋十二转，赏赐百千强。\n可汗问所欲，木兰不用尚书郎。\n愿驰千里足，送儿还故乡。\n爷娘闻女来，出郭相扶将。\n阿姊闻妹来，当户理红妆。\n小弟闻姊来，磨刀霍霍向猪羊。\n开我东阁门，坐我西阁床。\n脱我战时袍，著我旧时裳。\n当窗理云鬓，对镜帖花黄。\n出门看火伴，火伴皆惊忙。\n同行十二年，不知木兰是女郎。\n雄兔脚扑朔，雌兔眼迷离。\n双兔傍地走，安能辨我是雄雌？", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("送杜少府之任蜀州", "唐代", "王勃", "城阙辅三秦，风烟望五津。\n与君离别意，同是宦游人。\n海内存知己，天涯若比邻。\n无为在歧路，儿女共沾巾。", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("登幽州台歌", "唐代", "陈子昂", "前不见古人，后不见来者。\n念天地之悠悠，独怆然而涕下。", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("次北固山下", "唐代", "王湾", "客路青山外，行舟绿水前。\n潮平两岸阔，风正一帆悬。\n海日生残夜，江春入旧年。\n乡书何处达？归雁洛阳边。", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("使至塞上", "唐代", "王维", "单车欲问边，属国过居延。\n征蓬出汉塞，归雁入胡天。\n大漠孤烟直，长河落日圆。\n萧关逢候骑，都护在燕然。", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("闻王昌龄左迁龙标遥有此寄", "唐代", "李白", "杨花落尽子规啼，闻道龙标过五溪。\n我寄愁心与明月，随君直到夜郎西。", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("行路难", "唐代", "李白", "金樽清酒斗十千，玉盘珍羞直万钱。\n停杯投箸不能食，拔剑四顾心茫然。\n欲渡黄河冰塞川，将登太行雪满山。\n闲来垂钓碧溪上，忽复乘舟梦日边。\n行路难，行路难，多歧路，今安在？\n长风破浪会有时，直挂云帆济沧海。", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("黄鹤楼", "唐代", "崔颢", "昔人已乘黄鹤去，此地空余黄鹤楼。\n黄鹤一去不复返，白云千载空悠悠。\n晴川历历汉阳树，芳草萋萋鹦鹉洲。\n日暮乡关何处是？烟波江上使人愁。", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("望岳", "唐代", "杜甫", "岱宗夫如何？齐鲁青未了。\n造化钟神秀，阴阳割昏晓。\n荡胸生曾云，决眦入归鸟。\n会当凌绝顶，一览众山小。", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("春望", "唐代", "杜甫", "国破山河在，城春草木深。\n感时花溅泪，恨别鸟惊心。\n烽火连三月，家书抵万金。\n白头搔更短，浑欲不胜簪。", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("茅屋为秋风所破歌", "唐代", "杜甫", "八月秋高风怒号，卷我屋上三重茅。\n茅飞渡江洒江郊，高者挂罥长林梢，下者飘转沉塘坳。\n南村群童欺我老无力，忍能对面为盗贼。\n公然抱茅入竹去，唇焦口燥呼不得，归来倚杖自叹息。\n俄顷风定云墨色，秋天漠漠向昏黑。\n布衾多年冷似铁，娇儿恶卧踏里裂。\n床头屋漏无干处，雨脚如麻未断绝。\n自经丧乱少睡眠，长夜沾湿何由彻！\n安得广厦千万间，大庇天下寒士俱欢颜！\n风雨不动安如山。\n呜呼！何时眼前突兀见此屋，吾庐独破受冻死亦足！", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("白雪歌送武判官归京", "唐代", "岑参", "北风卷地白草折，胡天八月即飞雪。\n忽如一夜春风来，千树万树梨花开。\n散入珠帘湿罗幕，狐裘不暖锦衾薄。\n将军角弓不得控，都护铁衣冷难着。\n瀚海阑干百丈冰，愁云惨淡万里凝。\n中军置酒饮归客，胡琴琵琶与羌笛。\n纷纷暮雪下辕门，风掣红旗冻不翻。\n轮台东门送君去，去时雪满天山路。\n山回路转不见君，雪上空留马行处。", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("酬乐天扬州初逢席上见赠", "唐代", "刘禹锡", "巴山楚水凄凉地，二十三年弃置身。\n怀旧空吟闻笛赋，到乡翻似烂柯人。\n沉舟侧畔千帆过，病树前头万木春。\n今日听君歌一曲，暂凭杯酒长精神。", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("卖炭翁", "唐代", "白居易", "卖炭翁，伐薪烧炭南山中。\n满面尘灰烟火色，两鬓苍苍十指黑。\n卖炭得钱何所营？身上衣裳口中食。\n可怜身上衣正单，心忧炭贱愿天寒。\n夜来城外一尺雪，晓驾炭车辗冰辙。\n牛困人饥日已高，市南门外泥中歇。\n翩翩两骑来是谁？黄衣使者白衫儿。\n手把文书口称敕，回车叱牛牵向北。\n一车炭，千余斤，宫使驱将惜不得。\n半匹红纱一丈绫，系向牛头充炭直。", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("钱塘湖春行", "唐代", "白居易", "孤山寺北贾亭西，水面初平云脚低。\n几处早莺争暖树，谁家新燕啄春泥。\n乱花渐欲迷人眼，浅草才能没马蹄。\n最爱湖东行不足，绿杨阴里白沙堤。", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("雁门太守行", "唐代", "李贺", "黑云压城城欲摧，甲光向日金鳞开。\n角声满天秋色里，塞上燕脂凝夜紫。\n半卷红旗临易水，霜重鼓寒声不起。\n报君黄金台上意，提携玉龙为君死。", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("赤壁", "唐代", "杜牧", "折戟沉沙铁未销，自将磨洗认前朝。\n东风不与周郎便，铜雀春深锁二乔。", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("泊秦淮", "唐代", "杜牧", "烟笼寒水月笼沙，夜泊秦淮近酒家。\n商女不知亡国恨，隔江犹唱后庭花。", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("夜雨寄北", "唐代", "李商隐", "君问归期未有期，巴山夜雨涨秋池。\n何当共剪西窗烛，却话巴山夜雨时。", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("无题", "唐代", "李商隐", "相见时难别亦难，东风无力百花残。\n春蚕到死丝方尽，蜡炬成灰泪始干。\n晓镜但愁云鬓改，夜吟应觉月光寒。\n蓬山此去无多路，青鸟殷勤为探看。", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("相见欢", "五代", "李煜", "无言独上西楼，月如钩。\n寂寞梧桐深院锁清秋。\n剪不断，理还乱，是离愁。\n别是一般滋味在心头。", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("渔家傲·秋思", "宋代", "范仲淹", "塞下秋来风景异，衡阳雁去无留意。\n四面边声连角起，千嶂里，长烟落日孤城闭。\n浊酒一杯家万里，燕然未勒归无计。\n羌管悠悠霜满地，人不寐，将军白发征夫泪。", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("浣溪沙", "宋代", "晏殊", "一曲新词酒一杯，去年天气旧亭台。\n夕阳西下几时回？\n无可奈何花落去，似曾相识燕归来。\n小园香径独徘徊。", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("登飞来峰", "宋代", "王安石", "飞来山上千寻塔，闻说鸡鸣见日升。\n不畏浮云遮望眼，自缘身在最高层。", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("江城子·密州出猎", "宋代", "苏轼", "老夫聊发少年狂，左牵黄，右擎苍。\n锦帽貂裘，千骑卷平冈。\n为报倾城随太守，亲射虎，看孙郎。\n酒酣胸胆尚开张。\n鬓微霜，又何妨！\n持节云中，何日遣冯唐？\n会挽雕弓如满月，西北望，射天狼。", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("水调歌头", "宋代", "苏轼", "明月几时有？把酒问青天。\n不知天上宫阙，今夕是何年。\n我欲乘风归去，又恐琼楼玉宇，高处不胜寒。\n起舞弄清影，何似在人间。\n转朱阁，低绮户，照无眠。\n不应有恨，何事长向别时圆？\n人有悲欢离合，月有阴晴圆缺，此事古难全。\n但愿人长久，千里共婵娟。", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("渔家傲", "宋代", "李清照", "天接云涛连晓雾，星河欲转千帆舞。\n仿佛梦魂归帝所，闻天语，殷勤问我归何处。\n我报路长嗟日暮，学诗谩有惊人句。\n九万里风鹏正举。风休住，蓬舟吹取三山去！", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("游山西村", "宋代", "陆游", "莫笑农家腊酒浑，丰年留客足鸡豚。\n山重水复疑无路，柳暗花明又一村。\n箫鼓追随春社近，衣冠简朴古风存。\n从今若许闲乘月，拄杖无时夜叩门。", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("南乡子·登京口北固亭有怀", "宋代", "辛弃疾", "何处望神州？满眼风光北固楼。\n千古兴亡多少事？悠悠。\n不尽长江滚滚流。\n年少万兜鍪，坐断东南战未休。\n天下英雄谁敌手？曹刘。\n生子当如孙仲谋。", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("破阵子·为陈同甫赋壮词以寄之", "宋代", "辛弃疾", "醉里挑灯看剑，梦回吹角连营。\n八百里分麾下炙，五十弦翻塞外声，沙场秋点兵。\n马作的卢飞快，弓如霹雳弦惊。\n了却君王天下事，赢得生前身后名。可怜白发生！", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("过零丁洋", "宋代", "文天祥", "辛苦遭逢起一经，干戈寥落四周星。\n山河破碎风飘絮，身世浮沉雨打萍。\n惶恐滩头说惶恐，零丁洋里叹零丁。\n人生自古谁无死？留取丹心照汗青。", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("天净沙·秋思", "元代", "马致远", "枯藤老树昏鸦，小桥流水人家，古道西风瘦马。\n夕阳西下，断肠人在天涯。", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("山坡羊·潼关怀古", "元代", "张养浩", "峰峦如聚，波涛如怒，山河表里潼关路。\n望西都，意踌躇。\n伤心秦汉经行处，宫阙万间都做了土。\n兴，百姓苦；亡，百姓苦。", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("己亥杂诗", "清代", "龚自珍", "浩荡离愁白日斜，吟鞭东指即天涯。\n落红不是无情物，化作春泥更护花。", ["初中必背诗文", "义务课标2022", "7-9年级"]),
        requiredPoem("满江红", "近现代", "秋瑾", "小住京华，早又是中秋佳节。\n为篱下黄花开遍，秋容如拭。\n四面歌残终破楚，八年风味徒思浙。\n苦将侬强派作蛾眉，殊未屑！\n身不得，男儿列。\n心却比，男儿烈！\n算平生肝胆，因人常热。\n俗子胸襟谁识我？英雄末路当磨折。\n莽红尘何处觅知音？青衫湿！", ["初中必背诗文", "义务课标2022", "7-9年级"])
    ]

}

private extension Array {
    var only: Element? {
        count == 1 ? first : nil
    }
}

struct GaokaoPoetryQuestion: Identifiable {
    let id = UUID()
    let year: String
    let paper: String
    let poemTitle: String
    let author: String
    let prompt: String
    let question: String
    let answer: String
    let analysis: String

    static let sampleQuestionCount = 22

    static let sampleQuestions: [GaokaoPoetryQuestion] = [
        GaokaoPoetryQuestion(
            year: "2025",
            paper: "全国一卷",
            poemTitle: "名篇名句默写",
            author: "高考真题整理",
            prompt: "补写出下列句子中的空缺部分。开放性题目给出常见示例答案。",
            question: "（1）毕业典礼上，柳教授引用韩愈《师说》中勉励学生“青出于蓝而胜于蓝”的两句：__________，__________。\n（2）张老师给守卫边疆的丈夫发信息，引用秦观《鹊桥仙》中表示情长意久的两句：__________，__________。\n（3）与荷花图内容相契合的古诗文名句，可以是：__________，__________。",
            answer: "（1）（是故）弟子不必不如师；师不必贤于弟子。\n（2）两情若是久长时；又岂在朝朝暮暮。\n（3）示例：水面清圆，一一风荷举；或“接天莲叶无穷碧，映日荷花别样红”。",
            analysis: "本题有固定篇目默写和图像开放默写两类。固定题要扣住“青出于蓝”“情长意久”，开放题只要画面元素、意境和诗句对应即可。"
        ),
        GaokaoPoetryQuestion(
            year: "2025",
            paper: "全国二卷",
            poemTitle: "名篇名句默写",
            author: "高考真题整理",
            prompt: "补写出下列句子中的空缺部分。开放性题目给出常见示例答案。",
            question: "（1）音乐会报道引用苏轼《赤壁赋》中形容洞箫尾音婉转悠长、连绵不断的两句：__________，__________。\n（2）老年大学书法和茶艺教室的对联，可用陆游《临安春雨初霁》中的两句：__________，__________。\n（3）与山水行舟图内容相契合的古诗文名句，可以是：__________，__________。",
            answer: "（1）余音袅袅；不绝如缕。\n（2）矮纸斜行闲作草；晴窗细乳戏分茶。\n（3）示例：两岸青山相对出，孤帆一片日边来；或“客路青山外，行舟绿水前”。",
            analysis: "生活情境题要抓关键词：“洞箫尾音”对应《赤壁赋》乐声描写，“书法和茶艺”对应“闲作草”“戏分茶”。"
        ),
        GaokaoPoetryQuestion(
            year: "2024",
            paper: "新课标 I 卷",
            poemTitle: "名篇名句默写",
            author: "高考真题整理",
            prompt: "补写出下列句子中的空缺部分。第三小题为开放性答案示例。",
            question: "（1）《屈原列传》中，写寻常事物却表达宏大旨意、列举浅近事例却传达深远意蕴的两句：__________，__________。\n（2）民宿周围栽种多种树木，可联想到陶渊明《归园田居》（其一）中的两句：__________，__________。\n（3）唐代诗人常借汉喻唐、以古写今，如：__________，__________。",
            answer: "（1）其称文小而其指极大；举类迩而见义远。\n（2）榆柳荫后檐；桃李罗堂前。\n（3）示例：汉家烟尘在东北，汉将辞家破残贼。",
            analysis: "第一题要注意“指”通“旨”，“迩”是近。开放题只要同时符合唐诗、写时事、托汉代三项限制即可。"
        ),
        GaokaoPoetryQuestion(
            year: "2024",
            paper: "新课标 II 卷",
            poemTitle: "名篇名句默写",
            author: "高考真题整理",
            prompt: "补写出下列句子中的空缺部分。第三小题为开放性答案示例。",
            question: "（1）郊外春游时看到树木葱郁、水流淙淙，可联想到陶渊明《归去来兮辞》中的两句：__________，__________。\n（2）给在成都旅行的女儿发信息，希望她早点回家，可用李白《蜀道难》中的两句：__________，__________。\n（3）古诗中上下句分别写离别双方情思的例子，可以是：__________，__________。",
            answer: "（1）木欣欣以向荣；泉涓涓而始流。\n（2）锦城虽云乐；不如早还家。\n（3）示例：洛阳亲友如相问，一片冰心在玉壶。",
            analysis: "情境题先抓物象或语意：“树木、水流”对应“木欣欣、泉涓涓”；“成都、早回家”对应《蜀道难》锦城两句。"
        ),
        GaokaoPoetryQuestion(
            year: "2024",
            paper: "全国甲卷",
            poemTitle: "名篇名句默写",
            author: "高考真题整理",
            prompt: "补写出下列句子中的空缺部分。第三小题为开放性答案示例。",
            question: "（1）王湾《次北固山下》中描写时序交替、蕴含自然理趣的两句：__________，__________。\n（2）农家乐餐厅宣传横幅可直接使用陆游《游山西村》中的两句：__________，__________。\n（3）写瀑布飞泻、水石激荡、轰鸣作响的古诗句，可以是：__________，__________。",
            answer: "（1）海日生残夜；江春入旧年。\n（2）莫笑农家腊酒浑；丰年留客足鸡豚。\n（3）示例：飞湍瀑流争喧豗，砯崖转石万壑雷；或“飞流直下三千尺，疑是银河落九天”。",
            analysis: "注意易错字：“腊”“豚”“喧豗”“砯崖”。开放题要同时满足瀑布、声响、水石激荡。"
        ),
        GaokaoPoetryQuestion(
            year: "2023",
            paper: "新课标 I 卷",
            poemTitle: "名篇名句默写",
            author: "高考真题整理",
            prompt: "补写出下列句子中的空缺部分。第三小题为开放性答案示例。",
            question: "（1）司马迁《报任安书》中说自己编写《史记》尚未完成便遭遇李陵之祸，因痛惜此书不能完成而忍辱的句子：__________，__________。\n（2）李贺《李凭箜篌引》中说明竖箜篌弦数还有另一种可能的两句：__________，__________。\n（3）给诸葛亮画像题诗，可直接用古人成句，如：__________，__________。",
            answer: "（1）草创未就；（是以）就极刑而无愠色。\n（2）十二门前融冷光；二十三丝动紫皇。\n（3）示例：出师未捷身先死，长使英雄泪满襟。",
            analysis: "第一题易漏“就”，第二题易错“融”“紫皇”。诸葛亮题诗可用杜甫、陆游等相关名句。"
        ),
        GaokaoPoetryQuestion(
            year: "2023",
            paper: "新课标 II 卷",
            poemTitle: "名篇名句默写",
            author: "高考真题整理",
            prompt: "补写出下列句子中的空缺部分。第三小题为开放性答案示例。",
            question: "（1）《五代史·伶官传序》中写李存勖出兵作战前取箭、背负而行的两句：__________，__________。\n（2）陆游《临安春雨初霁》中看似闲适、实则暗含惆怅失眠的两句：__________，__________。\n（3）文天祥月下独步江边，可吟诵前人的写景名句：__________，__________。",
            answer: "（1）则遣从事以一少牢告庙；请其矢。\n（2）小楼一夜听春雨；深巷明朝卖杏花。\n（3）示例：星垂平野阔，月涌大江流。",
            analysis: "第二题关键词是“一夜”，它暗示彻夜难眠。开放题抓“月下、江边、壮阔景象”。"
        ),
        GaokaoPoetryQuestion(
            year: "2023",
            paper: "全国乙卷",
            poemTitle: "名篇名句默写",
            author: "高考真题整理",
            prompt: "补写出下列句子中的空缺部分。",
            question: "（1）白居易《琵琶行》中写琵琶女结束演奏后的动作神态，并引出身世叙述的两句：__________，__________。\n（2）张孝祥写舟泛洞庭，境界与苏轼《赤壁赋》中的两句相近：__________，__________。\n（3）鼓励别人相信人生仍有机遇，可引用李白《行路难》中的两句：__________，__________。",
            answer: "（1）沉吟放拨插弦中；整顿衣裳起敛容。\n（2）纵一苇之所如；凌万顷之茫然。\n（3）长风破浪会有时；直挂云帆济沧海。",
            analysis: "本题多考动作和意境对应，易错字有“拨”“弦”“敛”“苇”“顷”“沧”。"
        ),
        GaokaoPoetryQuestion(
            year: "2023",
            paper: "全国甲卷",
            poemTitle: "名篇名句默写",
            author: "高考真题整理",
            prompt: "补写出下列句子中的空缺部分。第三小题为开放性答案示例。",
            question: "（1）《邹忌讽齐王纳谏》中记载，齐王接受邹忌的意见，广开言路。一开始有很多人进谏，以至“__________”；过了几个月后，则“__________”。\n（2）鲍照曾以“对案不能食，拔剑击柱长叹息”表达内心愤懑，李白《行路难》中描写相近动作、抒写近似心情的两句：__________，__________。\n（3）花和雪都是古诗词中常见物象，古代诗人常常以雪喻花，或以花喻雪，比如：__________，__________。",
            answer: "（1）门庭若市；时时而间进。\n（2）停杯投箸不能食；拔剑四顾心茫然。\n（3）示例：忽如一夜春风来，千树万树梨花开。",
            analysis: "第一题是单句默写，第二题抓住“不能食”“拔剑”的动作相似点；开放题只要体现花雪互喻即可。"
        ),
        GaokaoPoetryQuestion(
            year: "2022",
            paper: "新高考 I 卷",
            poemTitle: "名篇名句默写",
            author: "高考真题整理",
            prompt: "补写出下列句子中的空缺部分。第三小题为开放性答案示例。",
            question: "（1）《荀子·劝学》中以劣马的执着为喻，强调为学必须持之以恒的两句：__________，__________。\n（2）《诗经·周南·关雎》中写到乐器的两句：__________，__________。\n（3）鸟类啼鸣引发悲思愁绪的唐宋诗词名句，可以是：__________，__________。",
            answer: "（1）驽马十驾；功在不舍。\n（2）琴瑟友之；钟鼓乐之。\n（3）示例：杨花落尽子规啼，闻道龙标过五溪。",
            analysis: "开放题要体现鸟鸣和悲思愁绪。易错字有“驽”“瑟”“子规”。"
        ),
        GaokaoPoetryQuestion(
            year: "2022",
            paper: "新高考 II 卷",
            poemTitle: "名篇名句默写",
            author: "高考真题整理",
            prompt: "补写出下列句子中的空缺部分。第三小题为开放性答案示例。",
            question: "（1）陶渊明《归园田居》（其一）中使用叠字，增添乡村远景平静安详之感的两句：__________，__________。\n（2）杜甫《蜀相》中自问自答、点明诸葛武侯祠位置的两句：__________，__________。\n（3）唐宋诗词中包含“京华”的名句，可以是：__________，__________。",
            answer: "（1）暧暧远人村；依依墟里烟。\n（2）丞相祠堂何处寻；锦官城外柏森森。\n（3）示例：世味年来薄似纱，谁令骑马客京华。",
            analysis: "第一题考叠字，“暧暧”常误写为“暖暖”。第三题只要含“京华”且出自唐宋诗词即可。"
        ),
        GaokaoPoetryQuestion(
            year: "2022",
            paper: "全国甲卷",
            poemTitle: "名篇名句默写",
            author: "高考真题整理",
            prompt: "补写出下列句子中的空缺部分。",
            question: "（1）《诗经·卫风·氓》中写男女主人公小时候欢乐相处的两句：__________，__________。\n（2）杜甫《登高》中都使用叠字，从听觉、视觉上突出对景伤怀的两句：__________，__________。\n（3）辛弃疾《永遇乐·京口北固亭怀古》中表现刘裕北伐气势的两句：__________，__________。",
            answer: "（1）总角之宴；言笑晏晏。\n（2）无边落木萧萧下；不尽长江滚滚来。\n（3）金戈铁马；气吞万里如虎。",
            analysis: "注意“宴”和“晏晏”不同；《登高》两句分别从落木和长江写秋景的阔大与悲凉。"
        ),
        GaokaoPoetryQuestion(
            year: "2022",
            paper: "全国乙卷",
            poemTitle: "名篇名句默写",
            author: "高考真题整理",
            prompt: "补写出下列句子中的空缺部分。",
            question: "（1）白居易《琵琶行》中写琵琶女娴熟演奏《霓裳》《六幺》的两句：__________，__________。\n（2）李商隐《锦瑟》中含有数目字、引发后世多种解读的两句：__________，__________。\n（3）龚自珍《己亥杂诗》中以落花归根为喻，表达辞官后仍关心国家前途的两句：__________，__________。",
            answer: "（1）轻拢慢捻抹复挑；初为《霓裳》后《六幺》。\n（2）锦瑟无端五十弦；一弦一柱思华年。\n（3）落红不是无情物；化作春泥更护花。",
            analysis: "本题易错字较多：“拢”“捻”“霓裳”“幺”“瑟”“弦”。"
        ),
        GaokaoPoetryQuestion(
            year: "2021",
            paper: "新高考 I 卷",
            poemTitle: "名篇名句默写",
            author: "高考真题整理",
            prompt: "补写出下列句子中的空缺部分。第三小题为开放性答案示例。",
            question: "（1）《庄子·逍遥游》中说，到郊野去的人只带一日之粮当天回来；到百里之外去的人，则需要“__________”；而去往千里之外的人，就必须“__________”。\n（2）《邹忌讽齐王纳谏》中，邹忌见到徐公后仔细观察，觉得自己不如徐公美，然后“__________，__________”，最终认定自己确实不如徐公美。\n（3）“三秦”作为地理名词，频繁在古诗词中出现，如：__________，__________。",
            answer: "（1）宿舂粮；三月聚粮。\n（2）窥镜而自视；又弗如远甚。\n（3）示例：城阙辅三秦，风烟望五津。",
            analysis: "第一题注意“舂”字；第二题抓住题干中的“然后”；开放题须包含“三秦”这一地理名词。"
        ),
        GaokaoPoetryQuestion(
            year: "2021",
            paper: "新高考 II 卷",
            poemTitle: "名篇名句默写",
            author: "高考真题整理",
            prompt: "补写出下列句子中的空缺部分。第三小题为开放性答案示例。",
            question: "（1）陶渊明《归园田居》（其一）中采用对仗句式、连用两个比喻，表达诗人对官场的厌倦以及对田园的向往的两句：__________，__________。\n（2）欧阳修《伶官传序》中感慨李存勖强盛时“__________，__________”，而衰败时却身死国灭，为天下笑。\n（3）“落木”在古典诗词中经常出现，如：__________，__________。",
            answer: "（1）羁鸟恋旧林；池鱼思故渊。\n（2）其意气之盛；可谓壮哉。\n（3）示例：无边落木萧萧下，不尽长江滚滚来。",
            analysis: "第一题关注“两个比喻”；第二题易漏“之”字；第三题要包含“落木”这一意象。"
        ),
        GaokaoPoetryQuestion(
            year: "2021",
            paper: "全国甲卷",
            poemTitle: "名篇名句默写",
            author: "高考真题整理",
            prompt: "补写出下列句子中的空缺部分。",
            question: "（1）《左传·庄公十年》中，曹刿确认齐军不是伪装败退进而决定追击，是因为“__________，__________”。\n（2）《庄子·逍遥游》引用《齐谐》称，大鹏迁往南海时“__________，__________”，乘着六月的大风飞去。\n（3）郦道元《三峡》中引用渔歌“__________，__________”来印证前文对哀猿长啸的描写。",
            answer: "（1）（吾）视其辙乱；望其旗靡。\n（2）水击三千里；抟扶摇而上者九万里。\n（3）巴东三峡巫峡长；猿鸣三声泪沾裳。",
            analysis: "注意“辙”“靡”“抟”“巫峡”“裳”等易错字，第一空可不写“吾”。"
        ),
        GaokaoPoetryQuestion(
            year: "2021",
            paper: "全国乙卷",
            poemTitle: "名篇名句默写",
            author: "高考真题整理",
            prompt: "补写出下列句子中的空缺部分。",
            question: "（1）乐曲演奏过程中的停顿也有情感表达作用，白居易《琵琶行》中对此进行说明的两句：__________，__________。\n（2）李煜《虞美人》中想到当年金陵宫殿、慨叹物是人非的两句：__________，__________。\n（3）范仲淹《岳阳楼记》中描写春日洞庭湖花草的两句：__________，__________。",
            answer: "（1）别有幽愁暗恨生；此时无声胜有声。\n（2）雕栏玉砌应犹在；只是朱颜改。\n（3）岸芷汀兰；郁郁青青。",
            analysis: "第一题抓住“停顿也有情感表达”；第三题注意“芷”“汀”的写法。"
        ),
        GaokaoPoetryQuestion(
            year: "2020",
            paper: "新高考 I 卷",
            poemTitle: "名篇名句默写",
            author: "高考真题整理",
            prompt: "补写出下列句子中的空缺部分。",
            question: "（1）《论语·先进》中写孔子的四个弟子侍坐时各言其志，子路说用三年治理一个饱经忧患的千乘之国，可以使百姓“__________，__________”。\n（2）李清照《一剪梅》中形象写出主人公无法排遣离情的两句：__________，__________。\n（3）辛弃疾《菩萨蛮·书江西造口壁》中写江水里不仅能看到江水，还能看到“__________”；北望故都，又“__________”，视线常被遮断。",
            answer: "（1）可使有勇；且知方也。\n（2）才下眉头；却上心头。\n（3）中间多少行人泪；可怜无数山。",
            analysis: "第三题是上下文情境提示，注意《菩萨蛮·书江西造口壁》的词句衔接。"
        ),
        GaokaoPoetryQuestion(
            year: "2020",
            paper: "新高考 II 卷",
            poemTitle: "名篇名句默写",
            author: "高考真题整理",
            prompt: "补写出下列句子中的空缺部分。",
            question: "（1）后世多将军队中的同事称为“袍泽”，这个词源自《诗经·秦风·无衣》中的两句：__________，__________。\n（2）杜甫《登岳阳楼》中，描写洞庭湖分断吴楚、吐纳日月的两句：__________，__________。\n（3）苏洵《六国论》中分析道，秦国战争以外所得土地远远多于战争所得，因此“__________，__________”，本来就不在于战争。",
            answer: "（1）与子同袍；与子同泽。\n（2）吴楚东南坼；乾坤日夜浮。\n（3）秦之所大欲；诸侯之所大患。",
            analysis: "第一题由“袍泽”定位《无衣》前两章，第二题注意“坼”；第三题要扣住“战争以外所得土地”。"
        ),
        GaokaoPoetryQuestion(
            year: "2020",
            paper: "全国 I 卷",
            poemTitle: "名篇名句默写",
            author: "高考真题整理",
            prompt: "补写出下列句子中的空缺部分。",
            question: "（1）《离骚》中对古代服饰“上衣下裳制”有所反映的两句：__________，__________。\n（2）马致远杂剧《青衫泪》根据白居易《琵琶行》改编，剧名来自诗中的两句：__________，__________。\n（3）苏轼《水调歌头》中自言想要重返天上但又有所顾虑，原因在于：__________，__________。",
            answer: "（1）制芰荷以为衣兮；集芙蓉以为裳。\n（2）座中泣下谁最多；江州司马青衫湿。\n（3）又恐琼楼玉宇；高处不胜寒。",
            analysis: "注意“芰荷”“裳”“琼楼玉宇”的字形，第二题要扣住“青衫泪”。"
        ),
        GaokaoPoetryQuestion(
            year: "2020",
            paper: "全国 II 卷",
            poemTitle: "名篇名句默写",
            author: "高考真题整理",
            prompt: "补写出下列句子中的空缺部分。",
            question: "（1）《荀子·劝学》中举例说，笔直的木材如果“__________”，就会弯曲到符合圆规的标准；即使再经曝晒也不会挺直，因为“__________”。\n（2）欧阳修《醉翁亭记》中称出游时的食物都可来自山间，肥美的鱼从溪水中捕捞出，所谓“__________，__________”；而用泉水酿制的美酒口味甘冽。\n（3）苏轼《赤壁赋》中发议论说，江水不停地流去“__________”；月亮时圆时缺“__________”。",
            answer: "（1）輮以为轮；輮使之然也。\n（2）临溪而渔；溪深而鱼肥。\n（3）而未尝往也；而卒莫消长也。",
            analysis: "第一题“輮”字较难，第三题要区分江水与月亮两组议论。"
        ),
        GaokaoPoetryQuestion(
            year: "2020",
            paper: "全国 III 卷",
            poemTitle: "名篇名句默写",
            author: "高考真题整理",
            prompt: "补写出下列句子中的空缺部分。",
            question: "（1）《论语·述而》中孔子指出，即使吃粗劣的食物、枕着胳膊睡觉也可以乐在其中，而“__________，__________”。\n（2）白居易《观刈麦》中写劳动者珍惜夏日时光，不顾劳累也忘记炎热的两句：__________，__________。\n（3）杜牧《阿房宫赋》中以排比夸张表现阿房宫的奢华，如写架起房梁的椽子“__________”，嘈杂的音乐声“__________”。",
            answer: "（1）不义而富且贵；于我如浮云。\n（2）力尽不知热；但惜夏日长。\n（3）多于机上之工女；多于市人之言语。",
            analysis: "第三题考查的是单句空，作答时要结合题干中的“椽子”“音乐声”定位。"
        )
    ]
}

private struct GaokaoQuestionListView: View {
    let onSelect: (GaokaoPoetryQuestion) -> Void

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: AppTheme.spacing_sm) {
                    Text("高考诗文真题")
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    Text("按近年高考名篇名句补写真题整理，含参考答案与解析提示。")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding(.vertical, AppTheme.spacing_sm)
            }

            Section("真题") {
                ForEach(GaokaoPoetryQuestion.sampleQuestions) { question in
                    Button(action: {
                        onSelect(question)
                    }) {
                        VStack(alignment: .leading, spacing: AppTheme.spacing_sm) {
                            Text(question.paper)
                                .font(.headline)
                                .foregroundColor(AppTheme.textPrimary)
                            Text("\(question.year) · \(question.poemTitle)")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .padding(.vertical, AppTheme.spacing_xs)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .background(AppTheme.backgroundColor)
    }
}

private struct GaokaoQuestionDetailView: View {
    let question: GaokaoPoetryQuestion
    @State private var showAnswer = false
    @State private var showAnalysis = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.spacing_lg) {
                VStack(alignment: .leading, spacing: AppTheme.spacing_sm) {
                    Text(question.paper)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)

                    Text("\(question.year) · \(question.author)")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                }

                GaokaoInfoBlock(title: "材料提示", content: question.prompt)
                GaokaoInfoBlock(title: "题目", content: question.question)

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showAnswer.toggle()
                    }
                }) {
                    DisclosureHeader(title: "参考答案", isExpanded: showAnswer)
                }

                if showAnswer {
                    GaokaoInfoBlock(title: nil, content: question.answer)
                }

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showAnalysis.toggle()
                    }
                }) {
                    DisclosureHeader(title: "解析思路", isExpanded: showAnalysis)
                }

                if showAnalysis {
                    GaokaoInfoBlock(title: nil, content: question.analysis)
                }
            }
            .padding(AppTheme.spacing_lg)
        }
        .background(AppTheme.backgroundColor.ignoresSafeArea())
        .navigationTitle(question.poemTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct GaokaoInfoBlock: View {
    let title: String?
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing_sm) {
            if let title = title {
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)
            }

            Text(content)
                .font(.body)
                .foregroundColor(AppTheme.textSecondary)
                .lineSpacing(5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.spacing_lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadius_md)
        .shadow(color: AppTheme.shadowColor, radius: AppTheme.shadowRadius, x: 0, y: 2)
    }
}

private struct DisclosureHeader: View {
    let title: String
    let isExpanded: Bool

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)

            Spacer()

            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppTheme.primaryColor)
        }
        .padding(AppTheme.spacing_lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadius_md)
    }
}

struct NavigationControllerReader: UIViewControllerRepresentable {
    let onResolve: (UINavigationController?) -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        ResolverViewController(onResolve: onResolve)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        DispatchQueue.main.async {
            onResolve(uiViewController.navigationController)
        }
    }

    private final class ResolverViewController: UIViewController {
        let onResolve: (UINavigationController?) -> Void

        init(onResolve: @escaping (UINavigationController?) -> Void) {
            self.onResolve = onResolve
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            self.onResolve = { _ in }
            super.init(coder: coder)
        }

        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
            DispatchQueue.main.async { [weak self] in
                self?.onResolve(self?.navigationController)
            }
        }
    }
}
