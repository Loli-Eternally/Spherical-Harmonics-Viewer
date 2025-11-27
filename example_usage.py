"""
球谐函数可视化示例
演示如何使用spherical_harmonics_3d模块绘制不同的球谐函数
"""

import matplotlib.pyplot as plt
from spherical_harmonics_3d import plot_spherical_harmonic_3d, plot_multiple_harmonics

def example_single_harmonics():
    """绘制几个单个球谐函数的例子"""
    harmonics = [
        (0, 0),   # s轨道
        (1, 0),   # p_z轨道
        (1, 1),   # p_x轨道（近似）
        (2, 0),   # d_z²轨道
        (2, 2),   # d_{x²-y²}轨道
        (3, 0),   # f轨道
    ]
    
    for l, m in harmonics:
        print(f"正在绘制 Y({l},{m})...")
        fig, ax = plot_spherical_harmonic_3d(l=l, m=m, figsize=(8, 8))
        filename = f'Y{l}{m}.png'
        plt.savefig(filename, dpi=200, bbox_inches='tight')
        print(f"已保存为 {filename}")
        plt.close()

def example_interactive():
    """交互式选择要绘制的球谐函数"""
    print("=== 球谐函数可视化工具 ===")
    print("输入要绘制的球谐函数的 l 和 m 值")
    print("(输入 q 退出)")
    
    while True:
        try:
            user_input = input("\n请输入 l 和 m (例如: 2 1): ").strip()
            if user_input.lower() == 'q':
                break
            
            parts = user_input.split()
            if len(parts) != 2:
                print("请输入两个数字，用空格分隔")
                continue
            
            l = int(parts[0])
            m = int(parts[1])
            
            if abs(m) > l:
                print(f"错误: |m| = {abs(m)} 必须 <= l = {l}")
                continue
            
            print(f"正在绘制 Y({l},{m})...")
            fig, ax = plot_spherical_harmonic_3d(l=l, m=m)
            filename = f'Y{l}{m}_interactive.png'
            plt.savefig(filename, dpi=200, bbox_inches='tight')
            print(f"已保存为 {filename}")
            plt.show()
            
        except ValueError:
            print("请输入有效的整数")
        except KeyboardInterrupt:
            print("\n\n退出程序")
            break
        except Exception as e:
            print(f"发生错误: {e}")

if __name__ == '__main__':
    import sys
    
    if len(sys.argv) > 1:
        mode = sys.argv[1]
        if mode == 'single':
            example_single_harmonics()
        elif mode == 'interactive':
            example_interactive()
        elif mode == 'multiple':
            print("正在绘制多个球谐函数...")
            fig = plot_multiple_harmonics(l_max=2)
            plt.savefig('all_harmonics.png', dpi=200, bbox_inches='tight')
            print("已保存为 all_harmonics.png")
            plt.show()
        else:
            print("用法: python example_usage.py [single|interactive|multiple]")
    else:
        # 默认运行单个示例
        print("绘制几个示例球谐函数...")
        print("(使用 'python example_usage.py interactive' 进入交互模式)")
        print("(使用 'python example_usage.py multiple' 查看所有低阶球谐函数)\n")
        
        example_single_harmonics()

