"""Helpers for the Visualizer reactor in FurutaViz.lf.

lfc copies this file next to the program.
theta is the pendulum angle. 0 is upright, pi is hanging down.
phi is the arm angle.
"""
import math

WIDTH = 41  # width of the gauge in characters


def wrap(angle):
    """Wrap an angle to (-pi, pi]."""
    return math.atan2(math.sin(angle), math.cos(angle))


def gauge(theta):
    """Draw the pendulum angle on one line. The middle is upright, the ends hang down."""
    pos = int(round((wrap(theta) / math.pi + 1) / 2 * (WIDTH - 1)))
    cells = ["."] * WIDTH
    cells[WIDTH // 2] = "|"
    cells[pos] = "O"
    return "down " + "".join(cells) + " down"


def save(samples, phases):
    """Write out/furuta.png and out/furuta.gif and return a message.

    samples has one (t, theta, phi, phase) tuple per reading.
    phases has one (start time, name) tuple per controller phase.
    """
    if not samples:
        return "no samples"
    ends = [start for start, _ in phases[1:]] + [samples[-1][0]]
    spans = [(start, end, name) for (start, name), end in zip(phases, ends)]
    render(samples, spans, "out/furuta.png", "out/furuta.gif")
    return "wrote out/furuta.png and out/furuta.gif"


def render(samples, phases, png_path, gif_path, fps=25):
    """Plot theta and phi over time with the controller phases shaded, then animate.

    phases has one (start, end, name) tuple per phase.
    """
    import matplotlib

    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    t = [s[0] for s in samples]
    theta = [math.degrees(wrap(s[1])) for s in samples]
    for i in range(1, len(theta)):          # break the line where it wraps at ±180°
        if abs(theta[i] - theta[i - 1]) > 180:
            theta[i - 1] = float("nan")
    phi = [math.degrees(s[2]) for s in samples]
    colors = {"swingUp": "#f4cccc", "catching": "#fff2cc", "stabilizing": "#d9ead3"}

    fig, (a1, a2) = plt.subplots(2, 1, sharex=True, figsize=(9, 5))
    for start, end, name in phases:
        for ax in (a1, a2):
            ax.axvspan(start, end, color=colors.get(name, "#eeeeee"), lw=0)
        if end - start > 0.15:                 # label only the phases wide enough to fit
            a1.text(start, 185, name, fontsize=8, va="bottom")
    a1.plot(t, theta, lw=1)
    a1.set_ylabel("pendulum θ [deg]\n(0 = upright)")
    a1.set_ylim(-200, 210)
    a2.plot(t, phi, lw=1, color="tab:orange")
    a2.set_ylabel("arm φ [deg]")
    a2.set_xlabel("logical time [s]")
    fig.tight_layout()
    fig.savefig(png_path, dpi=110)
    plt.close(fig)

    from matplotlib.animation import FuncAnimation, PillowWriter

    step = max(1, int(len(samples) / (t[-1] * fps))) if t[-1] > 0 else 1
    frames = samples[::step]
    fig = plt.figure(figsize=(4, 4))
    ax = fig.add_subplot(projection="3d")

    def draw(i):
        ts, th, ph = frames[i][:3]
        ax.cla()
        ax.set_xlim(-1.2, 1.2), ax.set_ylim(-1.2, 1.2), ax.set_zlim(-1.2, 1.2)
        ax.set_axis_off()
        arm = (math.cos(ph), math.sin(ph))
        # the pendulum swings in the plane perpendicular to the arm
        tip = (arm[0] - math.sin(th) * math.sin(ph) * 0.9,
               arm[1] + math.sin(th) * math.cos(ph) * 0.9,
               math.cos(th) * 0.9)
        ax.plot([0, 0], [0, 0], [-1.2, 0], color="grey", lw=4)
        ax.plot([0, arm[0]], [0, arm[1]], [0, 0], color="tab:blue", lw=4)
        ax.plot([arm[0], tip[0]], [arm[1], tip[1]], [0, tip[2]], color="tab:red", lw=3)
        ax.scatter([tip[0]], [tip[1]], [tip[2]], color="tab:red", s=40)
        ax.set_title(f"t = {ts:5.2f} s  {frames[i][3]}", fontsize=9)

    FuncAnimation(fig, draw, frames=len(frames)).save(gif_path, writer=PillowWriter(fps=fps))
    plt.close(fig)
