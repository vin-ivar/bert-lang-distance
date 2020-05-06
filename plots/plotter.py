import seaborn as sns
import pandas as pd
import sys
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

def avg_trend(task):
    frames = []
    if task == 'lower':
        task_array = ['dep', 'pos', 'ner']

    elif task == 'higher':
        task_array = ['qa_em', 'qa_f1', 'nli']

    elif task == 'all':
        task_array = ['qa_em', 'qa_f1', 'dep', 'pos', 'ner', 'nli']

    fig, axes = plt.subplots(ncols=3)
    for n, (i, ax) in enumerate(zip(task_array, axes)):
        df = pd.read_csv('{}.avg'.format(i), sep='\t', index_col=0).to_numpy()
        im = ax.imshow(df, vmin=40, vmax=100, cmap='bone_r')
        ax.set_xlabel(i.upper(), labelpad=7)
        ax.xaxis.set_label_position('top')
        ax.set_xticks(np.arange(6))
        ax.set_xticklabels([0, 10, 50, 100, 500, '1k'], fontsize=8)

        if n == 0:
            ax.set_yticks(np.arange(3))
            ax.set_yticklabels(['longest', 'rand', 'shortest'])
        else:
            ax.get_yaxis().set_visible(False)

        for i in range(3):
            for j in range(6):
                text = ax.text(j, i, '{:.2f}'.format(df[i, j]), ha="center", va="center", color="w", size=5)


    # cb_ax = fig.add_axes([0.190, 0.25, 0.70, 0.3])
    # cb_ax.set_axis_off()
    # cbar = fig.colorbar(im, ax=cb_ax, orientation='horizontal', aspect=40)
    # cbar.set_label('Metric')

    plt.tight_layout()

    # df = pd.concat(frames, keys=task_array).reset_index().rename(columns={'level_0': 'experiment'})
    # df['numel'] = pd.to_numeric(df['numel'])
    # df = df[df['sample'] == 'rand']
    # sns.lineplot(data=df, x='numel', y='score', hue='experiment', style='sample', sort=False, palette='Set2')
                    # order=['0', '2', '4', '6', '8', '10', '50', '100', '500', '1000'])

    figure = plt.gcf()
    # figure.set_size_inches(8, 6)
    plt.savefig('avg_heatmap.png', dpi=800, bbox_inches='tight')
    # plt.show()

def by_lang(task):
    frames = []
    if task == 'lower':
        task_array = ['dep', 'pos', 'ner']

    elif task == 'higher':
        task_array = ['xquad', 'xnli']

    for i in task_array:
        df = pd.read_csv('rand.{}.all'.format(i), sep='\t', index_col=0)
        df = df.unstack().reset_index().rename(columns={'level_0': 'lang', 0: 'score'})
        frames.append(df)

    df = pd.concat(frames, keys=task_array).reset_index().rename(columns={'level_0': 'experiment'})
    df = df[~df['lang'].isin(['en', 'fr', 'bg', 'sw', 'ur'])]
    ax1 = sns.stripplot(data=df, x='lang', y='score', hue='experiment',
                       palette=sns.color_palette([(0.3, 0.3, 0.3)]), dodge=True, size=2.5, jitter=0)
    ax2 = sns.boxplot(data=df, x='lang', y='score', hue='experiment', palette='Set2', whis=10, saturation=0.9)
    ax2.set_xlabel('Language')
    ax2.set_ylabel('Metric')
    ax2.legend().remove()

    patches = []
    for i, c in zip(task_array, sns.color_palette('Set2')):
        patches.append(mpatches.Patch(color=c, label=i.upper()))

    plt.legend(handles=patches, loc='lower right')
    plt.savefig('rand_{}.png'.format(task), dpi=800, bbox_inches='tight')
    # plt.show()

def deltas():

    tasks = ['pos', 'ner', 'dep', 'xnli', 'xquad']
    # tasks = ['pos']
    lims = [45, 40, 35, 49, 25]
    for n, (task, lim) in enumerate(zip(tasks, lims)):
        df = pd.read_csv('rand.{}.all'.format(task), sep='\t', header=0, index_col=0)

        df = df.unstack().reset_index().rename(columns={'level_0': 'lang', 0: 'score'})
        df = df[df['numel'].isin([0, 2, 6, 10, 100, 1000])]
        df = df[df['lang'] != 'en']


        ax = sns.barplot(data=df, x='lang', hue='numel', y='score', palette=sns.dark_palette(sns.color_palette('Set2')[n], reverse=True))
        ax.set_ylim(lim)
        ax.set_xlabel('Language')
        ax.set_ylabel('Metric')
        ax.legend(ncol=2)

        if task in ['ner', 'pos']:
            ax.legend(loc='upper left', ncol=4)

        # plt.show()
        plt.savefig('gains_{}.png'.format(task), dpi=800, bbox_inches='tight')
        #
        plt.close()

def main():
    fn = sys.argv[1]
    task = sys.argv[2]

    if fn == 'avg':
        avg_trend(task)

    if fn == 'lang':
        by_lang(task)

    if fn == 'delta':
        deltas()

main()