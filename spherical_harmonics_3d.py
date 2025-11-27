"""
3D球谐函数可视化
使用matplotlib绘制球谐函数的3D图像
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.special import sph_harm
from matplotlib import cm
import matplotlib
import platform

# 配置中文字体
system = platform.system()
if system == 'Windows':
    chinese_fonts = ['Microsoft YaHei', 'SimHei', 'KaiTi', 'FangSong', 'SimSun']
elif system == 'Darwin':
    chinese_fonts = ['Arial Unicode MS', 'PingFang SC', 'STHeiti', 'Heiti SC']
else:
    chinese_fonts = ['WenQuanYi Micro Hei', 'WenQuanYi Zen Hei', 'Noto Sans CJK SC']

current_fonts = list(matplotlib.rcParams.get('font.sans-serif', []))
matplotlib.rcParams['font.sans-serif'] = chinese_fonts + [f for f in current_fonts if f not in chinese_fonts]
matplotlib.rcParams['axes.unicode_minus'] = False

def spherical_harmonic_3d(l, m, resolution=50):
    """
    生成3D球谐函数数据
    
    参数:
        l: 角动量量子数 (整数)
        m: 磁量子数 (整数, -l <= m <= l)
        resolution: 分辨率 (默认50)
    
    返回:
        x, y, z: 3D坐标
        colors: 颜色值（归一化到[0,1]）
    """
    theta = np.linspace(0, np.pi, resolution)
    phi = np.linspace(0, 2*np.pi, resolution)
    theta_grid, phi_grid = np.meshgrid(theta, phi)
    
    # 计算球谐函数
    Y_lm = sph_harm(m, l, phi_grid, theta_grid)
    Y_real = Y_lm.real
    Y_abs = np.abs(Y_lm)
    
    # 使用绝对值作为半径，归一化
    r = Y_abs / Y_abs.max() * 0.5 if Y_abs.max() > 0 else Y_abs
    
    # 转换为笛卡尔坐标
    x = r * np.sin(theta_grid) * np.cos(phi_grid)
    y = r * np.sin(theta_grid) * np.sin(phi_grid)
    z = r * np.cos(theta_grid)
    
    # 归一化颜色到[0,1]
    Y_max = np.abs(Y_real).max()
    colors = (Y_real / Y_max + 1) / 2 if Y_max > 0 else np.zeros_like(Y_real)
    
    return x, y, z, colors

def plot_spherical_harmonic_3d(l, m, figsize=(10, 10), colormap='RdBu_r'):
    """
    绘制3D球谐函数
    
    参数:
        l: 角动量量子数
        m: 磁量子数
        figsize: 图形大小
        colormap: 颜色映射
    """
    if abs(m) > l:
        raise ValueError(f"|m| = {abs(m)} 必须 <= l = {l}")
    
    x, y, z, colors = spherical_harmonic_3d(l, m)
    
    fig = plt.figure(figsize=figsize)
    ax = fig.add_subplot(111, projection='3d')
    
    # 绘制表面
    ax.plot_surface(x, y, z, facecolors=cm.get_cmap(colormap)(colors),
                   rstride=1, cstride=1, alpha=0.9, linewidth=0.3,
                   antialiased=True, shade=True)
    
    # 设置标签和标题
    ax.set_xlabel('X', fontsize=12)
    ax.set_ylabel('Y', fontsize=12)
    ax.set_zlabel('Z', fontsize=12)
    ax.set_title(f'球谐函数 Y({l},{m}) 的3D图像', fontsize=14, fontweight='bold')
    
    # 设置相等的坐标轴比例
    max_range = np.array([x.max()-x.min(), y.max()-y.min(), z.max()-z.min()]).max() / 2.0
    mid_x = (x.max()+x.min()) * 0.5
    mid_y = (y.max()+y.min()) * 0.5
    mid_z = (z.max()+z.min()) * 0.5
    ax.set_xlim(mid_x - max_range, mid_x + max_range)
    ax.set_ylim(mid_y - max_range, mid_y + max_range)
    ax.set_zlim(mid_z - max_range, mid_z + max_range)
    
    # 添加颜色条
    mappable = cm.ScalarMappable(cmap=cm.get_cmap(colormap))
    mappable.set_array(colors)
    plt.colorbar(mappable, ax=ax, shrink=0.5, aspect=20, label='归一化的球谐函数值')
    
    plt.tight_layout()
    return fig, ax

def plot_multiple_harmonics(l_max=2, figsize=(15, 15)):
    """
    绘制多个球谐函数的子图
    
    参数:
        l_max: 最大l值
        figsize: 图形大小
    """
    cols = l_max + 1
    rows = 2 * l_max + 1
    fig = plt.figure(figsize=figsize)
    
    plot_idx = 1
    for l in range(l_max + 1):
        for m in range(-l, l + 1):
            x, y, z, colors = spherical_harmonic_3d(l, m, resolution=30)
            ax = fig.add_subplot(rows, cols, plot_idx, projection='3d')
            
            ax.plot_surface(x, y, z, facecolors=cm.get_cmap('RdBu_r')(colors),
                          rstride=1, cstride=1, alpha=0.9, linewidth=0.1)
            
            ax.set_title(f'Y({l},{m})', fontsize=8)
            ax.set_xticks([])
            ax.set_yticks([])
            ax.set_zticks([])
            
            plot_idx += 1
    
    plt.tight_layout()
    return fig

if __name__ == '__main__':
    # 示例1: 绘制单个球谐函数 Y(2,1)
    print("正在绘制球谐函数 Y(2,1)...")
    fig1, ax1 = plot_spherical_harmonic_3d(l=2, m=1)
    plt.savefig('spherical_harmonic_Y21.png', dpi=300, bbox_inches='tight')
    print("已保存为 spherical_harmonic_Y21.png")
    
    # 示例2: 绘制多个低阶球谐函数
    print("\n正在绘制多个球谐函数...")
    fig2 = plot_multiple_harmonics(l_max=2)
    plt.savefig('spherical_harmonics_multiple.png', dpi=300, bbox_inches='tight')
    print("已保存为 spherical_harmonics_multiple.png")
    
    plt.show()
